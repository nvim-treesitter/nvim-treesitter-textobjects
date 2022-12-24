def set_cursor(nvim, row, col):
    """
    Normally, nvim's set cursor functions count from (1, 0).
    To make it consistent with events, we need to count from (0, 0).
    """
    nvim.current.window.cursor = (row + 1, col)
