def get_visual_range(nvim, input_keys):
    """
    Go to normal mode,
    Select the text object using the key bindings,
    Return the range of the text object,

    Raise an exception if the buffer content has changed during the execution.
    Do this by letting pynvim instance listens to `on_byte` event. It should not be triggered.
    """
    pass
