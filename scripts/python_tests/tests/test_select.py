from nvim_communicator import receive_all_pending_messages


def test_select_function(nvim):
    nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))
    nvim.command("normal vam")
    nvim.feedkeys(nvim.replace_termcodes("<esc>", True, True, True))
    events = receive_all_pending_messages(nvim)
    for event in events:
        assert event[1] != "on_bytes"
        assert event[1] != "on_bytes_removed"

    assert events[-1][1] == "visual_leave"
    assert events[-1][2] == ["v", "n", 19, 4, 24, 37]
