import logging
import time

import pynvim

logger = logging.getLogger(__name__)


class NvimAttachTimeoutError(Exception):
    pass


class NvimInitError(Exception):
    pass


def wait_until_attached_socket(socket_path, timeout=100):
    for _ in range(timeout * 10):
        try:
            nvim = pynvim.attach("socket", path=socket_path)
        except Exception:
            time.sleep(0.1)
        else:
            break
    else:
        logger.error("Timeout while waiting for nvim to start")
        raise NvimAttachTimeoutError("Timeout while waiting for nvim to start")

    return nvim


def wait_until_attached_tcp(address, port, timeout=100):
    for _ in range(timeout * 10):
        try:
            nvim = pynvim.attach("tcp", address=address, port=port)
        except Exception:
            time.sleep(0.1)
        else:
            break
    else:
        logger.error("Timeout while waiting for nvim to start")
        raise NvimAttachTimeoutError("Timeout while waiting for nvim to start")

    return nvim


def init_nvim_communicator(nvim, lua_file_paths):
    existing_channel_id = nvim.vars.get("nvim_communicator_channel_id", None)
    buffer_id = nvim.current.buffer

    if existing_channel_id is None:
        logger.info("Initialising..")
        logger.info(f"Communicating with {nvim.channel_id = }")
        nvim.vars["nvim_communicator_channel_id"] = nvim.channel_id
        nvim.vars["nvim_communicator_buffer_id"] = buffer_id
        nvim.vars["nvim_communicator_num_pending_msgs"] = 0
        # Define helper functions
        # Must come at the beginning
        for lua_file_path in lua_file_paths:
            with open(lua_file_path, "r") as f:
                lua_code = f.read()
            nvim.exec_lua(lua_code)

    elif existing_channel_id < 0:
        logger.info("Communicator already initialised on nvim, but has exited before.")
        logger.info("Just changing the channel ID and buffer")
        # Already initialised, but exited once
        nvim.vars["nvim_communicator_channel_id"] = nvim.channel_id
        nvim.vars["nvim_communicator_buffer_id"] = buffer_id
        nvim.vars["nvim_communicator_num_pending_msgs"] = 0
    else:
        logger.error("Communicator already running on another side.")
        raise NvimInitError("Communicator already running on another side.")


def exit_nvim_communicator(nvim):
    # Before exiting, tell vim about it.
    # Otherwise vim will need to communicate once more to find out.
    try:
        nvim.vars["nvim_communicator_channel_id"] = -1
    except Exception:
        # Even if you fail it's not a big problem
        pass
