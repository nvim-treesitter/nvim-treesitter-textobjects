from nvim_communicator import receive_all_pending_messages, events_to_listdict


def test_select_function(nvim):
    nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))
    nvim.command("normal vam")
    nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))
    events = receive_all_pending_messages(nvim)
    events = events_to_listdict(events)
    for event in events:
        assert event["name"] != "on_bytes"
        assert event["name"] != "on_bytes_removed"

    assert events[-2]["name"] == "visual_leave"
    assert events[-2]["args"] == {
        "old_mode": "v",
        "new_mode": "n",
        "start_row": 19,
        "start_col": 4,
        "end_row": 24,
        "end_col": 37,
    }
    assert events[-1]["name"] == "CursorMoved"
    assert events[-1]["args"] == {
        "cursor_pos_row": 24,
        "cursor_pos_col": 37,
    }
