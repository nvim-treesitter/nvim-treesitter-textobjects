import os
from pathlib import Path
import tempfile

import pytest
import requests

from nvim_communicator import pynvim_helpers

SOURCE_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
LUA_DIR = SOURCE_DIR / ".." / "lua"
PACKPATH = "~/.local/share/nvim/site"


@pytest.fixture(scope="session")
def nvim():
    with tempfile.TemporaryDirectory() as tmp:
        path = os.path.join(tmp, "nvim")
        os.system(f"nvim --clean --headless --listen {path} &")
        nvim = pynvim_helpers.wait_until_attached_socket(path, timeout=100)

        nvim.command(f"set packpath+={PACKPATH}")
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

        yield nvim

        # Teardown
        try:
            nvim.command("qa!")
        except Exception:
            # ignore teardown errors because the pynvim will
            # lose connection and raise an error
            pass
