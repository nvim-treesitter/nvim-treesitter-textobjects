def get_last_selection_range(nvim):
    """
    Get the last selection range.
    Index from (0,0), and start and end are inclusive.
    """
    start_pos = nvim.funcs.getpos("'<")
    end_pos = nvim.funcs.getpos("'>")
    return (start_pos[1] - 1, start_pos[2] - 1, end_pos[1] - 1, end_pos[2] - 1)
