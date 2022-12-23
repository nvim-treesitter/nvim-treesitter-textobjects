# Nvim_communicator Python Package

This project is made for testing neovim plugins, specifically focussing on Nvim-treesitter-textobjects for now.

It uses pynvim to communicate with neovim, executing lua scripts or input keys and then return the results.


## Installation

```bash
pip install -e .						# requirements for running tools
pip install -r requirements_dev.txt		# requirements for running tests
```

You can bypass installing and just run `tox` (`pip install tox` still required) if all you want is to run tests. 

## Using the demo

To understand the logic of the testing, it is recommended to try the demos in `tools`.  

1. Add symlink of this repo to `~/.local/share/nvim/site/pack/tests/opt/nvim-treesitter-textobjects` and  
also add `nvim-treesitter` to `~/.local/share/nvim/site/pack/tests/opt/nvim-treesitter`.
2. Launch nvim with `nvim --clean --listen localhost:28905`.
3. In another terminal, launch `tools/event_demo.py`
  - This will load a sample code, select a function, then grab the selection area with `visual_leave` event.
  - Then it will delete from that cursor to the end of the class.
4. Launch `tools/event_playground.py` and move around the vim file to see what events you can receive.
5. Once you saw it working, run `pytest`. It will essentially do the same thing. It is just a template for now, but we need to make more tests.
  - The coverage report is reporting test coverage of this python test program, not the treesitter-textobjects. You can ignore this report.

## Note
Test templated follows [this mCoding YouTube](https://youtu.be/DhUpxWjOhME).
