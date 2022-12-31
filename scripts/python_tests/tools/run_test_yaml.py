#!/use/bin/env python3

import argparse
import logging
from multiprocessing import Pool
import os
from pathlib import Path
import re
import sys
import tempfile
import time

import coloredlogs
import pynvim
import requests
import tqdm
import yaml

from nvim_communicator import pynvim_helpers
from nvim_communicator import (
    events_to_listdict,
    receive_all_pending_messages,
    set_cursor,
)
import verboselogs

logger = verboselogs.VerboseLogger(__name__)
SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / ".." / "lua"


class OnBytesException(Exception):
    pass


nvim: pynvim.Nvim | None = None


def init_nvim(filepath, packpath):
    global nvim
    with tempfile.TemporaryDirectory() as tmp:
        listen_path = os.path.join(tmp, "nvim")
        os.system(
            f"nvim --clean --headless --listen {listen_path} '{filepath}' 1> /dev/null 2> /dev/null &"
        )
        nvim = pynvim_helpers.wait_until_attached_socket(listen_path, timeout=100)

        nvim.command(f"set packpath+={packpath}")
        nvim.command("packadd nvim-treesitter")
        nvim.command("packadd nvim-treesitter-textobjects")

        nvim.command("TSUpdate")

        pynvim_helpers.init_nvim_communicator(
            nvim,
            [
                LUA_DIR / "treesitter_init.lua",
                LUA_DIR / "helpers.lua",
                LUA_DIR / "event_on_byte.lua",
                LUA_DIR / "autocmd_cursormoved.lua",
                LUA_DIR / "autocmd_cursormoved_i.lua",
                LUA_DIR / "autocmd_visualenter.lua",
                LUA_DIR / "autocmd_visualleave.lua",
                LUA_DIR / "autocmd_vimleave.lua",
            ],
        )

        nvim.input("<esc>")


def run_test_visual(row, col, feedkeys, test_result_ground_truth, filepath, packpath):
    global nvim
    global logger

    if nvim is None:
        init_nvim(filepath, packpath)
        if nvim is None:
            raise RuntimeError("Failed to initialize nvim")

    try:
        set_cursor(nvim, row, col)

        nvim.feedkeys(feedkeys)

        # WARNING: Do NOT use nvim.feedkeys() for ESC here as it will block when vim is in operator pending mode.
        # Spam ESC to exit operator pending / input / visual mode.
        for _ in range(5):
            nvim.input("<esc>")

        for _ in range(5):
            nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))

        events = receive_all_pending_messages(nvim)
        events_d = events_to_listdict(events)
        for event in events_d:
            if event["name"].startswith("on_bytes"):
                raise OnBytesException(
                    f"on_bytes event should not be triggered but got {event}"
                )

        # time.sleep(1)
        # events = receive_all_pending_messages(nvim)
        # events_d.extend(events_to_listdict(events))
        # for event in events_d:
        #     if event["name"].startswith("on_bytes"):
        #         raise OnBytesException(f"on_bytes event should not be triggered but got {event}")

        if events_d[-1]["name"] == "CursorMoved":
            visual_leave_event_idx = -2
        else:
            visual_leave_event_idx = -1
        assert (
            events_d[visual_leave_event_idx]["name"] == "visual_leave"
        ), f"Expected visual_leave event, got {events_d[visual_leave_event_idx]['name']}"

        visual_leave_event = events_d[visual_leave_event_idx]["args"]
        test_results = {
            "mode": visual_leave_event["old_mode"],
            "range": [
                visual_leave_event["start_row"],
                visual_leave_event["start_col"],
                visual_leave_event["end_row"],
                visual_leave_event["end_col"],
            ],
        }

        assert (
            test_results == test_result_ground_truth
        ), f"Test result does not match: {test_results}, {test_result_ground_truth}"
    except OnBytesException:
        for _ in range(5):
            nvim.input("<esc>")
        nvim.command("earlier 1f")
        events = receive_all_pending_messages(nvim)

        logger.exception(f"Test failed for row {row}, col {col}, feedkeys {feedkeys}")
        return False
    except AssertionError:
        for _ in range(5):
            nvim.input("<esc>")
        events = receive_all_pending_messages(nvim)

        logger.exception(f"Test failed for row {row}, col {col}, feedkeys {feedkeys}")
        return False
    except Exception:
        # Reinitialise nvim
        try:
            for _ in range(5):
                nvim.input("<esc>")
            nvim.command("qa!")
        except Exception:
            # ignore teardown errors because the pynvim will
            # lose connection and raise an error
            pass
        nvim = None
        logger.exception(f"Test crashed for row {row}, col {col}, feedkeys {feedkeys}")
        return False

    return True


def run_test_visual_star(params):
    return run_test_visual(*params)


def get_parser():
    parser = argparse.ArgumentParser(
        description="Generate tests for the nvim-communicator plugin."
        "Run nvim with `--clean --listen localhost:28905` to use this script."
        "DO NOT interact with nvim during the execution. It will generate wrong events (wrong test samples)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("test_yaml_path", help="test yaml to read")
    parser.add_argument(
        "--packpath",
        default="~/.local/share/nvim/site",
        help="Path to search packages. "
        "The packages should be located at `pack/*/opt/nvim-treesitter` and "
        "`pack/*/opt/nvim-treesitter-textobjects`. "
        "The latter should be a symlink of this repo.",
    )
    return parser


def main():
    coloredlogs.install(
        fmt="%(name)s: %(lineno)4d - %(levelname)s - %(message)s", level=logging.INFO
    )

    parser = get_parser()
    args = parser.parse_args()

    try:
        # TODO: Generalise this programme. For now, it assumes python file and only perform select visual mode.
        # TODO: Lookahead, lookbehind, include_whitespaces options

        logger.info(f"Reading {args.test_yaml_path}")
        with open(args.test_yaml_path, "r") as f:
            tests_info = yaml.safe_load(f)

        URL = tests_info["URL"]
        # grab content from URL
        response = requests.get(URL)
        # get filename from URL using content-disposition
        content_disposition = response.headers.get("content-disposition")
        if content_disposition:
            filename = re.findall("filename=(.+)", content_disposition)[0]
        else:
            filename = URL.split("/")[-1]

        # save content to file in temp directory
        with tempfile.TemporaryDirectory() as tmpdirname:
            filepath = Path(tmpdirname) / filename
            logger.info(f"Saving {URL} to {filepath}")
            with open(filepath, "w") as f:
                f.write(response.text)

            params = []
            for test_info in tests_info["tests"]:
                assert (
                    test_info["test"] == "visual"
                ), f"Only visual test is supported, got {test_info['test']}"
                if test_info["test"] == "visual":
                    params.append(
                        (
                            test_info["actions"]["cursor_pos"][0],
                            test_info["actions"]["cursor_pos"][1],
                            test_info["actions"]["feedkeys"],
                            test_info["results"],
                            filepath,
                            args.packpath,
                        )
                    )

            logger.info(f"Running {len(params)} tests")

            # Testing without multiprocessing
            # for param in params:
            #     run_test_visual(*param)

            with Pool() as pool:
                results = list(
                    tqdm.tqdm(
                        pool.imap(run_test_visual_star, params), total=len(params)
                    )
                )

        num_tests = len(results)
        num_success = sum(results)
        num_failed = num_tests - num_success
        if num_failed > 0:
            logger.error(f"{num_failed} tests failed out of {num_tests}")
        else:
            logger.success(f"All {num_tests} tests passed")

    except Exception:
        logger.exception("Exception occurred")

    try:
        global nvim
        if nvim is not None:
            nvim.command("qa!")
    except Exception:
        # ignore teardown errors because the pynvim will
        # lose connection and raise an error
        pass

    try:
        if num_failed > 0:
            sys.exit(1)
    except UnboundLocalError:
        pass


if __name__ == "__main__":
    main()
