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
