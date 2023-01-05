# Nvim_communicator Python Package

[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

This project is made for testing neovim plugins, specifically focussing on Nvim-treesitter-textobjects for now.

It uses pynvim to communicate with neovim, executing lua scripts or input keys and then return the results.

## Installation

If using conda,

```bash
pip install -e .						# requirements for running tools
pip install -r requirements_dev.txt		# requirements for running tests
```

If running on the system python, add `--user`.

You can bypass installing and just run `tox` if all you want is to run tests.  
You still need to `pip install tox` and follow "Using the demo - 1." Add symlink of the plugins.

## Using the demo

To understand the logic of the testing, it is recommended to try the demos in `tools`.

1. Add symlink of this repo to `~/.local/share/nvim/site/pack/tests/opt/nvim-treesitter-textobjects` and  
   also add `nvim-treesitter` to `~/.local/share/nvim/site/pack/tests/opt/nvim-treesitter`.
2. Launch nvim with `nvim --clean --listen localhost:28905`.
3. In another terminal, launch `tools/event_demo.py`

- This will load a sample code, select a function, then grab the selection area with `visual_leave` event.
- Then it will delete from that cursor to the end of the class.

4. Launch `tools/event_playground.py` and move around the vim file to see what events you can receive.

<img src=https://user-images.githubusercontent.com/12980409/209483465-99d4059e-3f25-4652-a86a-aacf6d04a5de.gif width=100%>

5. Once you saw it working, run `pytest`. It will essentially do the same thing. It is just a template for now, but we need to make more tests.

- The coverage report is reporting test coverage of this python test program, not the treesitter-textobjects. You can ignore this report.

6. You can automatically generate tests with pseudo ground-truths using `tools/auto_generate_tests.py`.  
   Run `tools/auto_generate_tests_demo.py --sleep 1` and see how it works.  
   <img src=https://user-images.githubusercontent.com/12980409/209483492-c7ab0e3c-bc35-47cf-a0be-2396021ff1d9.gif width=100%>

## Note

- Test templated follows [this mCoding YouTube](https://youtu.be/DhUpxWjOhME).
- Event name is PascalCase if it's vim's autocmd (e.g. VimLeave, CursorMoved)
- Event name is snake_case if it's a custom event (e.g. on_bytes, on_bytes_removed, visual_enter, visual_leave)

## More test ideas

- On a function node start, going function back and forth should result in the same position (as long as there are enough functions)
- `3]m` equals to `]m2]m`
- `3]m` equals to `5]m[m[m`
- swap repeat check similarly
