#!/use/bin/env python3

import argparse
import logging
import os
from pathlib import Path
import sys
import time

import coloredlogs
import pynvim
import requests
logger = logging.getLogger(__name__)
SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / '..' / 'lua'


def get_parser():
    parser = argparse.ArgumentParser(description="Control nvim from python",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--nvim_addr", default = '127.0.0.1', help="")
    parser.add_argument("--nvim_port", default = 28905, help="")
    parser.add_argument("--socket_path", help="Specify this if you want to communicate with Neovim over a socket (file) instead of TCP.")
    return parser


def main():
    coloredlogs.install(fmt='%(name)s: %(lineno)4d - %(levelname)s - %(message)s', level=logging.INFO)

    parser = get_parser()
    args = parser.parse_args()

    logger.info("nvim addr: %s", args.nvim_addr)
    logger.info("nvim port: %s", args.nvim_port)
    logger.info("socket path: %s", args.socket_path)

    for _ in range(1000):
        try:
            if args.socket_path is not None:
                nvim = pynvim.attach('socket', path=args.socket_path)
            else:
                nvim = pynvim.attach('tcp', address=args.nvim_addr, port=args.nvim_port)
        except Exception as e:
            time.sleep(0.1)
        else:
            break
    else:
        logger.error('Timeout while waiting for nvim to start')
        sys.exit(51)


    existing_channel_id = nvim.vars.get('nvim_communicator_channel_id', None)
    buffer_id = nvim.current.buffer

    # Read file from URL
    response = requests.get('https://raw.githubusercontent.com/pytorch/pytorch/fc4acd4425ca0896ca1c4f0a8bd7e22a51e94731/torch/nn/modules/loss.py')
    content = response.text
    content = content.split('\n')

    # This will modify the entire buffer
    nvim.current.buffer[:] = content

    if existing_channel_id is None:
        logger.info("Initialising..")
        logger.info(f"Communicating with {nvim.channel_id = }")
        nvim.vars['nvim_communicator_channel_id'] = nvim.channel_id
        nvim.vars['nvim_communicator_buffer_id'] = buffer_id
        # Define helper functions
        # Must come at the beginning
        with open(LUA_DIR / 'treesitter_init.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        with open(LUA_DIR / 'helpers.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        # event throwers
        with open(LUA_DIR / 'event_on_byte.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        with open(LUA_DIR / 'autocmd_cursormoved.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        with open(LUA_DIR / 'autocmd_cursormoved_i.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        with open(LUA_DIR / 'autocmd_visualenter.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        with open(LUA_DIR / 'autocmd_visualleave.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

        with open(LUA_DIR / 'autocmd_vimleave.lua', 'r') as f:
            lua_code = f.read()
        nvim.exec_lua(lua_code)

    elif existing_channel_id < 0:
        logger.info("Communicator already initialised on nvim, but has exited before.")
        logger.info("Just changing the channel ID and buffer")
        # Already initialised, but exited once
        nvim.vars['nvim_communicator_channel_id'] = nvim.channel_id
        nvim.vars['nvim_communicator_buffer_id'] = buffer_id
    else:
        logger.error("Communicator already running on another side. Exiting..")
        sys.exit(53)


    try:
        pass

    except Exception as e:
        logger.exception("Exception occurred")

    # Before exiting, tell vim about it.
    # Otherwise vim will need to communicate once more to find out.
    try:
        nvim.vars['nvim_communicator_channel_id'] = -1
    except:
        # Even if you fail it's not a big problem
        pass


if __name__ == '__main__':
    main()
