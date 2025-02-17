wget "https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim-linux-x86_64.tar.gz"
tar -zxf nvim-linux-x86_64.tar.gz
sudo ln -s "$(pwd)/nvim-linux-x86_64/bin/nvim" /usr/local/bin
rm -rf "$(pwd)/nvim-linux-x86_64/lib/nvim/parser"
mkdir -p ~/.local/share/nvim/site/pack/ci/opt
ln -s "$(pwd)" ~/.local/share/nvim/site/pack/ci/opt
