#!/bin/bash

USERNAME=$(whoami)

function install_package () {
    PACKAGE_NAME=$1
    if [ -f /etc/debian_version ]; then
        echo "install $PACKAGE_NAME from apt"
        sudo apt install -y $PACKAGE_NAME
    elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        echo "install $PACKAGE_NAME from dnf"
        sudo dnf install -y $PACKAGE_NAME
    else
        echo "unsupported OS distribution. please manually install package: $1"
        # skip error
    fi
}

PACKAGES=(
    git
    make
    automake
    gcc
    gcc-c++
    g++
    kernel-devel
    vim
    tmux
    zsh
)

echo "setting packages..."
for pack in "${PACKAGES[@]}"; do
    install_package $pack
done

echo "setting oh-my-zsh..."
if [ ! -d "/home/$USERNAME/.oh-my-zsh" ]; then
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

curl -fLo /home/$USERNAME/.oh-my-zsh/themes/ https://raw.githubusercontent.com/luswdev/linux-user-defines/main/jtriley-custom.zsh-theme

echo "setting zsh.."
zsh
curl -fLo /home/$USERNAME https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.zshrc
source /home/$USERNAME/.zshrc

echo "setting zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
install_package autojump-zsh

echo "seting vim..."
curl -fLo /home/$USERNAME https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.vimrc

echo "setting tmux..."
curl -fLo /home/$USERNAME https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source /home/$USERNAME/.tmux.conf

