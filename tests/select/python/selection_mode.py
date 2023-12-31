class Test:
    def __init__(self, *arg):
        my_list = []

        for arg_ in arg:
            my_list.append(arg_)

        self.my_list = my_list
