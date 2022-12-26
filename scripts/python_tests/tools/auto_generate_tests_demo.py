#!/use/bin/env python3

import argparse
import logging
import os
from pathlib import Path
import sys
import time

import coloredlogs
import requests

from nvim_communicator import pynvim_helpers
from nvim_communicator import (
    receive_all_pending_messages,
    set_cursor,
    events_to_listdict,
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
    "aC",
    "iC",
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
]


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
        help="",
    )
    parser.add_argument(
        "--sleep", type=int, default=0, help="Add sleep between actions to visualise."
    )

    parser.add_argument("--nvim_addr", default="127.0.0.1", help="")
    parser.add_argument("--nvim_port", default=28905, help="")
    parser.add_argument(
        "--socket_path",
        help="Specify this if you want to communicate with Neovim over a socket (file) instead of TCP.",
    )
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

    logger.info("nvim addr: %s", args.nvim_addr)
    logger.info("nvim port: %s", args.nvim_port)
    logger.info("socket path: %s", args.socket_path)

    try:
        if args.socket_path is not None:
            nvim = pynvim_helpers.wait_until_attached_socket(
                args.socket_path, timeout=100
            )
        else:
            nvim = pynvim_helpers.wait_until_attached_tcp(
                args.nvim_addr, args.nvim_port, timeout=100
            )
    except pynvim_helpers.NvimAttachTimeoutError:
        logger.exception("Could not connect to nvim")
        sys.exit(1)

    try:
        # This is the path to the plugins that will be loaded into nvim.
        nvim.command(f"set packpath+={args.packpath}")
        nvim.command("packadd nvim-treesitter")
        nvim.command("packadd nvim-treesitter-textobjects")

        nvim.command("TSUpdate")

        # Read file from URL
        response = requests.get(
            "https://raw.githubusercontent.com/pytorch/pytorch/fc4acd4425ca0896ca1c4f0a8bd7e22a51e94731/torch/nn/modules/loss.py"
        )
        content = response.text
        content = content.split("\n")

        # This will modify the entire buffer
        nvim.current.buffer[:] = content
        nvim.command("set filetype=python")

        # Better cursor visualisation
        nvim.command("set cursorline")
        nvim.command("set cursorcolumn")

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

        # TODO: Generalise this programme. For now, it assumes python file and only perform select visual mode.
        # TODO: Lookahead, lookbehind, include_whitespaces options
        nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))

        row_len = len(nvim.current.buffer)
        for row in range(row_len):
            for col in range(len(nvim.current.buffer[row])):
                for visual_mode in VISUAL_MODES:
                    for action in ACTIONS:
                        logger.info(f"Setting cursor to row {row} and col {col}")
                        set_cursor(nvim, row, col)

                        if args.sleep > 0:
                            time.sleep(args.sleep)

                        logger.info(
                            f"Performing action {action} in visual mode {visual_mode}"
                        )
                        nvim.feedkeys(
                            nvim.replace_termcodes(visual_mode, True, True, True)
                        )
                        nvim.feedkeys(action)

                        events = receive_all_pending_messages(nvim)
                        for event in events:
                            assert not event[0].startswith(
                                "on_bytes"
                            ), f"on_bytes event should not be triggered but got {event[0]}"
                            logger.info(f"Event from nvim: {event}")

                        if args.sleep > 0:
                            # To visually show what's going on, we sleep for 2 seconds.
                            time.sleep(args.sleep)

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
                        for event in events_d:
                            logger.info(f"Event from nvim: {event}")

                        if args.sleep > 0:
                            time.sleep(args.sleep)
                        # TODO: save events as YAML

    except Exception:
        logger.exception("Exception occurred")

    pynvim_helpers.exit_nvim_communicator(nvim)


if __name__ == "__main__":
    main()
