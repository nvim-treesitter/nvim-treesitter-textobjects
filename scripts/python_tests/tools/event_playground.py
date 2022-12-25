#!/use/bin/env python3

import argparse
import logging
import os
from pathlib import Path
import sys

import coloredlogs

from nvim_communicator import pynvim_helpers, receive_message

logger = logging.getLogger(__name__)
SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / ".." / "lua"


def get_parser():
    parser = argparse.ArgumentParser(
        description="Get events as you use nvim. Try typing in insert mode, moving around, visual mode enter and leave etc."
        "Run nvim with `--clean --listen localhost:28905` to use this script.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--nvim_addr", default="127.0.0.1", help="Nvim listen address")
    parser.add_argument("--nvim_port", default=28905, help="Nvim listen port")
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

        # Start event loop
        while True:
            event = receive_message(nvim)
            logger.info(f"Event from nvim: {event}")

            if event is None:
                logger.error("Received event=None")
                break

            if event[0] not in ["notification", "request"]:
                logger.error("Received event[0] not in ['notification', 'request']")
                logger.error(event[0])
                break
            else:
                if event[0] == "request":
                    event[3].send(None)

                if event[1] == "on_bytes_remove":
                    (
                        start_row,
                        start_col,
                        byte_offset,
                        old_end_row,
                        old_end_col,
                        old_end_byte_length,
                    ) = event[2]
                elif event[1] == "on_bytes":
                    (
                        changed_bytes,
                        start_row,
                        start_col,
                        byte_offset,
                        new_end_row,
                        new_end_col,
                        new_end_byte_length,
                    ) = event[2]
                elif event[1] == "CursorMoved":
                    cursor_pos_row, cursor_pos_col = event[2]
                    # Grab visual range
                elif event[1] == "CursorMovedI":
                    cursor_pos_row, cursor_pos_col = event[2]
                elif event[1] == "visual_enter":
                    old_mode, new_mode = event[2]
                elif event[1] == "visual_leave":
                    old_mode, new_mode, start_row, start_col, end_row, end_col = event[
                        2
                    ]
                elif event[1] == "grab_entire_buf":
                    buf = event[2][0]
                    print(buf)
                elif event[1] == "VimLeave":
                    logger.info("Nvim closed. Exiting")
                    break

    except Exception:
        logger.exception("Exception occurred")

    pynvim_helpers.exit_nvim_communicator(nvim)


if __name__ == "__main__":
    main()
