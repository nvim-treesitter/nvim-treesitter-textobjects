#!/use/bin/env python3

import argparse
import logging
import os
from pathlib import Path
import sys

import coloredlogs
import requests

from nvim_communicator import pynvim_helpers
logger = logging.getLogger(__name__)
SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / '..' / 'lua'


def get_parser():
    parser = argparse.ArgumentParser(description="Demo of using a sample code on the internet, performing some actions and printing events.",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--nvim_addr", default = '127.0.0.1', help="")
    parser.add_argument("--nvim_port", default = 28905, help="")
    parser.add_argument("--socket_path", help="Specify this if you want to communicate with Neovim over a socket (file) instead of TCP.")
    return parser


def nvim_set_cursor(nvim, row, col):
    """ 
    Normally, nvim's set cursor functions count from (1, 0).
    To make it consistent with events, we need to count from (0, 0).
    """
    nvim.current.window.cursor = (row+1, col)


def main():
    coloredlogs.install(fmt='%(name)s: %(lineno)4d - %(levelname)s - %(message)s', level=logging.INFO)

    parser = get_parser()
    args = parser.parse_args()

    logger.info("nvim addr: %s", args.nvim_addr)
    logger.info("nvim port: %s", args.nvim_port)
    logger.info("socket path: %s", args.socket_path)

    try:
        if args.socket_path is not None:
            nvim = pynvim_helpers.wait_until_attached_socket(args.socket_path, timeout = 100)
        else:
            nvim = pynvim_helpers.wait_until_attached_tcp(args.nvim_addr, args.nvim_port, timeout = 100)
    except pynvim_helpers.NvimAttachTimeoutError:
        logger.exception("Could not connect to nvim")
        sys.exit(1)

    # Read file from URL
    response = requests.get('https://raw.githubusercontent.com/pytorch/pytorch/fc4acd4425ca0896ca1c4f0a8bd7e22a51e94731/torch/nn/modules/loss.py')
    content = response.text
    content = content.split('\n')

    # This will modify the entire buffer
    nvim.current.buffer[:] = content
    nvim.command('set filetype=python')

    try:
        nvim_set_cursor(nvim, 3, 2)
        #nvim.exec_lua('vim.api.nvim_win_set_cursor(0, {1, 1})')
        pynvim_helpers.init_nvim_communicator(nvim, [
                                                  LUA_DIR / 'treesitter_init.lua',
                                                  LUA_DIR / 'helpers.lua',
                                                  LUA_DIR / 'event_on_byte.lua',
                                                  LUA_DIR / 'autocmd_cursormoved.lua',
                                                  LUA_DIR / 'autocmd_cursormoved_i.lua',
                                                  LUA_DIR / 'autocmd_visualenter.lua',
                                                  LUA_DIR / 'autocmd_visualleave.lua',
                                                  LUA_DIR / 'autocmd_vimleave.lua',
                                              ])

        # Go to visual mode
        nvim.feedkeys(nvim.replace_termcodes('<esc>', True, True, True))
        #nvim.feedkeys('viw')
        nvim.command('normal viw')
        nvim.feedkeys(nvim.replace_termcodes('<esc>', True, True, True))

        while nvim._session._pending_messages:
            event = nvim.next_message()
            logger.info(f'Event from nvim: {event}')

            if event is None:
                logger.error("Received event=None")
                break

            if event[0] != 'notification':
                logger.error("Received event[0] != 'notification'")
                logger.error(event[0])
                break
            else:
                if event[1] == 'on_byte_remove':
                    (start_row, start_col, byte_offset,
                     old_end_row, old_end_col, old_end_byte_length,
                    ) = event[2]
                elif event[1] == 'on_byte':
                    (changed_bytes, start_row, start_col, byte_offset,
                     new_end_row, new_end_col, new_end_byte_length) = event[2]
                elif event[1] == 'CursorMoved':
                    cursor_pos_row, cursor_pos_col = event[2]
                    # Grab visual range
                elif event[1] == 'CursorMovedI':
                    cursor_pos_row, cursor_pos_col = event[2]
                elif event[1] == 'visual_enter':
                    old_mode, new_mode = event[2]
                elif event[1] == 'visual_leave':
                    old_mode, new_mode, start_row, start_col, end_row, end_col = event[2]
                elif event[1] == 'grab_entire_buf':
                    buf = event[2][0]
                    print(buf)
                elif event[1] == 'VimLeave':
                    logger.info("Nvim closed. Exiting")
                    break

    except Exception as e:
        logger.exception("Exception occurred")

    pynvim_helpers.exit_nvim_communicator(nvim)


if __name__ == '__main__':
    main()
