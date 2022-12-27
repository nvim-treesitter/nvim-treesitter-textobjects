#!/usr/bin/env bash
# Kill all nvim processes that are created by `auto_generate_tests.py`.
ps -aux | grep 'nvim --clean --headless --listen /tmp' | awk '{print $2}' | xargs kill
