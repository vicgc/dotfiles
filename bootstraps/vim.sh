#!/usr/bin/env sh

# Download sources and compile vim
hg clone https://vim.googlecode.com/hg/ vim_source
cd vim_source
hg pull
hg update
hg update v7-4
sudo apt-get install libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev
./configure --enable-pythoninterp --with-python-config-dir=/usr/lib/python2.7/config \
    --enable-rubyinterp --with-features=huge --enable-gui=gtk2 --with-compiledby=Zoresvit
make -j 8
sudo checkinstall -y
cd ..
sudo rm -rf vim_source

# Populate configuration files
VIMHOME="$HOME/.vim"

if [ ! -L $HOME/.vimrc ]
then
    echo "Symlinking .vimrc..."
    ln -bns $VIMHOME/.vimrc $HOME/.vimrc
fi

if [ ! -L $HOME/.gvimrc ]
then
    echo "Symlinking .gvimrc..."
    ln -bns $VIMHOME/.gvimrc $HOME/.gvimrc
fi

# Setup bundle plugin manager
if [ ! -d "$VIMHOME/bundle" ]
then
    echo "Setting up Vundle..."
    mkdir -p "$VIMHOME/bundle"
    git clone https://github.com/gmarik/vundle.git $VIMHOME/bundle/vundle

    echo "Install plugins..."
    vim +BundleInstall! +qall
    echo "Done."
fi

echo "Install dependencies..."
sudo pip install nose vim_bridge ipdb
sudo rm -rf build
