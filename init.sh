#!/bin/bash

USERNAME="$(whoami)"

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

function supports_truecolor () {
    case "$COLORTERM" in
        truecolor|24bit) return 0 ;;
    esac

    case "$TERM" in
        iterm           |\
        tmux-truecolor  |\
        linux-truecolor |\
        xterm-truecolor |\
        screen-truecolor) return 0 ;;
    esac

    return 1
}


if [ -t 1 ]; then
    function is_tty () {
        true
    }
else
    function is_tty () {
        false
    }
fi

function setup_color () {
    # Only use colors if connected to a terminal
    if ! is_tty; then
        FMT_RAINBOW=""
        FMT_RED=""
        FMT_GREEN=""
        FMT_YELLOW=""
        FMT_BLUE=""
        FMT_BOLD=""
        FMT_RESET=""
        return
    fi

    if supports_truecolor; then
        FMT_RAINBOW="
            $(printf '\033[38;2;255;0;0m')
            $(printf '\033[38;2;255;97;0m')
            $(printf '\033[38;2;247;255;0m')
            $(printf '\033[38;2;0;255;30m')
            $(printf '\033[38;2;77;0;255m')
            $(printf '\033[38;2;168;0;255m')
            $(printf '\033[38;2;245;0;172m')
            $(printf '\033[38;2;255;0;0m')
        "
    else
        FMT_RAINBOW="
            $(printf '\033[38;5;196m')
            $(printf '\033[38;5;202m')
            $(printf '\033[38;5;226m')
            $(printf '\033[38;5;082m')
            $(printf '\033[38;5;021m')
            $(printf '\033[38;5;093m')
            $(printf '\033[38;5;163m')
            $(printf '\033[38;5;196m')
        "
    fi

    FMT_RED=$(printf '\033[31m')
    FMT_GREEN=$(printf '\033[32m')
    FMT_YELLOW=$(printf '\033[33m')
    FMT_BLUE=$(printf '\033[34m')
    FMT_BOLD=$(printf '\033[1m')
    FMT_RESET=$(printf '\033[0m')
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
    echo "install oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

curl -fLo /home/$USERNAME/.oh-my-zsh/themes/jtriley-custom.zsh-theme https://raw.githubusercontent.com/luswdev/linux-user-defines/main/jtriley-custom.zsh-theme

echo "setting zsh..."
sudo chsh -s /bin/zsh "$USERNAME"
curl -fLo /home/$USERNAME/.zshrc https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.zshrc

echo "setting zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
install_package autojump-zsh

echo "seting vim..."
curl -fLo /home/$USERNAME/.vimrc https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.vimrc
curl -fLo /home/$USERNAME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c 'PlugInstall' -c 'qall!'

echo "setting tmux..."
curl -fLo /home/$USERNAME/.tmux.conf https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

setup_color

printf "\n"
printf "\t %s o8o  %s            %s o8o  %s    .        %s      .o8  %s          %s            %s          %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %s \`\"'  %s            %s \`\"'  %s  .o8        %s     \"888  %s          %s            %s          %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %soooo  %sooo. .oo.   %soooo  %s.o888oo      %s .oooo888  %s .ooooo.  %sooo. .oo.   %s .ooooo.  %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %s\`888  %s\`888P\"Y88b  %s\`888  %s  888        %sd88' \`888  %sd88' \`88b %s\`888P\"Y88b  %sd88' \`88b %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %s 888  %s 888   888  %s 888  %s  888        %s888   888  %s888   888 %s 888   888  %s888ooo888 %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %s 888  %s 888   888  %s 888  %s  888 .      %s888   888  %s888   888 %s 888   888  %s888    .o %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %so888o %so888o o888o %so888o %s  \"888\"      %s\`Y8bod88P\" %s\`Y8bod8P' %so888o o888o %s\`Y8bod8P' %s\n" $FMT_RAINBOW $FMT_RESET
printf "\n"                                                

printf "run \"%ssource /home/$USERNAME/.zshrc%s\" manually to initial zsh\n" $FMT_YELLOW $FMT_RESET
printf "run \"%stmux source /home/$USERNAME/.tmux.conf%s\" manually to initial tmux\n" $FMT_YELLOW $FMT_RESET

