#!/use/bin/env python3

import tqdm
import random
import argparse
import logging
from multiprocessing import Pool
import os
from pathlib import Path
import tempfile

import coloredlogs
import pynvim
import re
import requests
import yaml

from nvim_communicator import pynvim_helpers
from nvim_communicator import (
    events_to_listdict,
    receive_all_pending_messages,
    set_cursor,
)

logger = logging.getLogger(__name__)
SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / ".." / "lua"

# VISUAL_MODES = ["v", "V", "<C-v>"]
# TODO: Dense generate 'v' mode but sparse generate 'V' and '<C-v>' mode
VISUAL_MODES = ["v"]
ACTIONS = [
    "am",
    "im",
    "al",
    "il",
    "ab",
    "ib",
    "ad",
    "id",
    "ao",
    "io",
    "aa",
    "ia",
    "af",
    "if",
    "ac",
    "ar",
    "ir",
    "at",
    "it",
    "ae",
    "ie",
    "as",
    "is",
    "]m",
    "]f",
    "]d",
    "]o",
    "]s",
    "]a",
    "]c",
    "]b",
    "]l",
    "]r",
    "]t",
    "]e",
    "]]m",
    "]]f",
    "]]d",
    "]]o",
    "]]a",
    "]]b",
    "]]l",
    "]]r",
    "]]t",
    "]]e",
    "]M",
    "]F",
    "]D",
    "]O",
    "]S",
    "]A",
    "]C",
    "]B",
    "]L",
    "]R",
    "]T",
    "]E",
    "]]M",
    "]]F",
    "]]D",
    "]]O",
    "]]A",
    "]]B",
    "]]L",
    "]]R",
    "]]T",
    "]]E",
    "[m",
    "[f",
    "[d",
    "[o",
    "[s",
    "[a",
    "[c",
    "[b",
    "[l",
    "[r",
    "[t",
    "[e",
    "[[m",
    "[[f",
    "[[d",
    "[[o",
    "[[a",
    "[[b",
    "[[l",
    "[[r",
    "[[t",
    "[[e",
    "[M",
    "[F",
    "[D",
    "[O",
    "[S",
    "[A",
    "[C",
    "[B",
    "[L",
    "[R",
    "[T",
    "[E",
    "[[M",
    "[[F",
    "[[D",
    "[[O",
    "[[A",
    "[[B",
    "[[L",
    "[[R",
    "[[T",
    "[[E",
]

nvim: pynvim.Nvim | None = None


def init_nvim(filepath, packpath):
    global nvim
    with tempfile.TemporaryDirectory() as tmp:
        listen_path = os.path.join(tmp, "nvim")
        os.system(
            f"nvim --clean --headless --listen {listen_path} '{filepath}' > /dev/null 2> /dev/null &"
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

        nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))


def generate_test_visual(row, col, feedkeys):
    global nvim
    global logger

    if nvim is None:
        return None

    # logger.info(f"Setting cursor to row {row} and col {col}")
    set_cursor(nvim, row, col)

    # logger.info(f"Performing action {feedkeys}")
    nvim.feedkeys(feedkeys)

    events = receive_all_pending_messages(nvim)
    events_d = events_to_listdict(events)
    for event in events_d:
        assert not event["name"].startswith(
            "on_bytes"
        ), f"on_bytes event should not be triggered but got {event['name']}"
        # logger.info(f"Event from nvim: {event}")

    nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))

    # Print all messages so far.
    # WARNING: do not use nvim.next_message() as it will lose track of how many messages have been received.
    # We need that info in order to receive all messages without having to wait and add timeout.

    # len(events) is 1 if the selection is not made. (visual_leave)
    # len(events) is 2 if the selection is made. (visual_leave, CursorMoved)
    events = receive_all_pending_messages(nvim)
    assert len(events) in [
        1,
        2,
    ], f"Expected 1 or 2 events, got {len(events)}, events: {events}"

    events_d = events_to_listdict(events)
    assert (
        events_d[0]["name"] == "visual_leave"
    ), f"Expected visual_leave event, got {events_d[0]['name']}"

    if len(events_d) == 2:
        assert (
            events_d[1]["name"] == "CursorMoved"
        ), f"Expected CursorMoved event, got {events_d[1]['name']}"
    # for event in events_d:
    #     logger.info(f"Event from nvim: {event}")

    visual_leave_event = events_d[0]["args"]
    test_info = {
        "test": "visual",
        "actions": {"cursor_pos": [row, col], "feedkeys": feedkeys},
        "results": {
            "mode": visual_leave_event["old_mode"],
            "range": [
                visual_leave_event["start_row"],
                visual_leave_event["start_col"],
                visual_leave_event["end_row"],
                visual_leave_event["end_col"],
            ],
        },
    }

    return test_info


def generate_test_visual_star(params):
    return generate_test_visual(*params)


def get_parser():
    parser = argparse.ArgumentParser(
        description="Generate tests for the nvim-communicator plugin."
        "Run nvim with `--clean --listen localhost:28905` to use this script."
        "DO NOT interact with nvim during the execution. It will generate wrong events (wrong test samples)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--URL",
        default="https://raw.githubusercontent.com/pytorch/pytorch/fc4acd4425ca0896ca1c4f0a8bd7e22a51e94731/torch/nn/modules/loss.py",
        help="File to use for testing",
    )
    parser.add_argument("--seed", default=0, type=int, help="Random seed")
    parser.add_argument(
        "--num_tests", default=10_000, type=int, help="Number of tests to generate"
    )
    parser.add_argument("--output", default="test.yaml", help="Output yaml file path")
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

    random.seed(args.seed)

    try:
        # TODO: Generalise this programme. For now, it assumes python file and only perform select visual mode.
        # TODO: Lookahead, lookbehind, include_whitespaces options

        # grab content from URL
        response = requests.get(args.URL)
        # get filename from URL using content-disposition
        content_disposition = response.headers.get("content-disposition")
        if content_disposition:
            filename = re.findall("filename=(.+)", content_disposition)[0]
        else:
            filename = args.URL.split("/")[-1]

        # save content to file in temp directory
        with tempfile.TemporaryDirectory() as tmpdirname:
            filepath = Path(tmpdirname) / filename
            logger.info(f"Saving {args.URL} to {filepath}")
            with open(filepath, "w") as f:
                f.write(response.text)

            # Open nvim to check basic row and col length of the file.
            # Nvim is probably not needed for this, but still doing this for consistency.
            with tempfile.TemporaryDirectory() as tmp:
                listen_path = os.path.join(tmp, "nvim")
                os.system(
                    f"nvim --clean --headless --listen {listen_path} '{filepath}' &"
                )
                temp_nvim = pynvim_helpers.wait_until_attached_socket(
                    listen_path, timeout=100
                )

                params = []
                row_len = len(temp_nvim.current.buffer)
                for row in range(row_len):
                    for col in range(len(temp_nvim.current.buffer[row])):
                        for visual_mode in VISUAL_MODES:
                            for action in ACTIONS:
                                params.append((row, col, f"{visual_mode}{action}"))

                try:
                    temp_nvim.command("qa!")
                except Exception:
                    # ignore teardown errors because the pynvim will
                    # lose connection and raise an error
                    pass

            params = random.sample(params, args.num_tests)
            commit = os.popen(f"git -C '{SOURCE_DIR}' rev-parse HEAD").read().strip()
            tests_info = {"commit": commit, "URL": args.URL, "seed": args.seed}

            with Pool(
                initializer=init_nvim, initargs=(filepath, args.packpath)
            ) as pool:
                results = list(
                    tqdm.tqdm(
                        pool.imap(generate_test_visual_star, params), total=len(params)
                    )
                )

            tests_info["tests"] = results
            with open(args.output, "w") as f:
                # sort_keys=False to preserve the order of the keys
                yaml.dump(tests_info, f, sort_keys=False)

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


if __name__ == "__main__":
    main()
