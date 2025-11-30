class Test:
    def __init__(self, *arg):
        my_list = []

        for arg_ in arg:
            my_list.append(arg_)

        self.my_list = my_list

        # see https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/700
        print(1, type('1'), ['1'])
        print(['1', '2'], 3)
        print(['1', '2'])
