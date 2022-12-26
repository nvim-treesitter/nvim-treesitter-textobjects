def receive_message(nvim):
    event = nvim.next_message()
    nvim.vars["nvim_communicator_num_pending_msgs"] -= 1
    return event


def receive_all_pending_messages(nvim):
    """
    Receive all pending messages from Neovim, by counting the number of messages that are already sent.

    If we just do
    ```
    while nvim._session._pending_messages:
        event = nvim.next_message()
    ```
    it doesn't guarantee to grab all messages that are previously sent. So we add a variable to count the number of meesages we received so far.
    """
    events = []
    while nvim.vars["nvim_communicator_num_pending_msgs"] > 0:
        event = nvim.next_message()
        nvim.vars["nvim_communicator_num_pending_msgs"] -= 1
        events.append(event)
    return events


def event_to_dict(event):
    event_dict = {}
    if event is None:
        return event_dict

    event_dict["type"] = event[0]  # request / notification
    # on_bytes / on_bytes_remove, CursorMoved, CursorMovedI, visual_enter, visual_leave, grab_entire_buf, VimLeave
    event_dict["name"] = event[1]
    event_args = {}

    if event[1] == "on_bytes_remove":
        (
            event_args["start_row"],
            event_args["start_col"],
            event_args["byte_offset"],
            event_args["old_end_row"],
            event_args["old_end_col"],
            event_args["old_end_byte_length"],
        ) = event[2]
    elif event[1] == "on_bytes":
        (
            event_args["changed_bytes"],
            event_args["start_row"],
            event_args["start_col"],
            event_args["byte_offset"],
            event_args["new_end_row"],
            event_args["new_end_col"],
            event_args["new_end_byte_length"],
        ) = event[2]
    elif event[1] == "CursorMoved":
        (
            event_args["cursor_pos_row"],
            event_args["cursor_pos_col"],
        ) = event[2]
    elif event[1] == "CursorMovedI":
        (
            event_args["cursor_pos_row"],
            event_args["cursor_pos_col"],
        ) = event[2]
    elif event[1] == "visual_enter":
        (
            event_args["old_mode"],
            event_args["new_mode"],
        ) = event[2]
    elif event[1] == "visual_leave":
        (
            event_args["old_mode"],
            event_args["new_mode"],
            event_args["start_row"],
            event_args["start_col"],
            event_args["end_row"],
            event_args["end_col"],
        ) = event[2]
    elif event[1] == "grab_entire_buf":
        event_args["buf"] = event[2][0]
    elif event[1] == "VimLeave":
        pass

    event_dict["args"] = event_args
    return event_dict


def events_to_listdict(events):
    return [event_to_dict(event) for event in events]
