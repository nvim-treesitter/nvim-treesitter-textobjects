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
from nvim_communicator import set_cursor, receive_all_pending_messages

logger = logging.getLogger(__name__)
SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / ".." / "lua"


def get_parser():
    parser = argparse.ArgumentParser(
        description="Demo of using a sample code on the internet, performing some actions and printing events."
        "Run nvim with `--clean --listen localhost:28905` to use this script.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
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

        logger.info("Select the first function")
        nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))
        # nvim.feedkeys('viw')
        nvim.command("normal vam")

        # Print all messages so far.
        # WARNING: do not use nvim.next_message() as it will lose track of how many messages have been received.
        # We need that info in order to receive all messages without having to wait and add timeout.
        events = receive_all_pending_messages(nvim)
        for event in events:
            logger.info(f"Event from nvim: {event}")

        # To visually show what's going on, we sleep for 2 seconds.
        time.sleep(2)
        logger.info("Print selection area with visual_leave event")
        nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))
        events = receive_all_pending_messages(nvim)
        for event in events:
            logger.info(f"Event from nvim: {event}")

        time.sleep(2)
        logger.info(
            "Move to the first function argument and remove to the end of the class"
        )
        set_cursor(nvim, 3, 2)
        time.sleep(2)
        nvim.feedkeys("]m")
        time.sleep(2)
        nvim.feedkeys("]a")
        time.sleep(2)
        nvim.feedkeys("dv][")
        events = receive_all_pending_messages(nvim)
        for event in events:
            logger.info(f"Event from nvim: {event}")

    except Exception:
        logger.exception("Exception occurred")

    pynvim_helpers.exit_nvim_communicator(nvim)


if __name__ == "__main__":
    main()
