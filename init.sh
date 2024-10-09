#!/bin/bash

USERNAME="$(whoami)"

function install_package () {
    PACKAGE_NAME=$1
    if [ -f /etc/debian_version ]; then
        INSTALLED=$(apt list --installed | grep $PACKAGE_NAME)
        if [ "$INSTALLED" == "" ]; then
            printf "installing %s$PACKAGE_NAME%s from apt...\n" $FMT_CYAN $FMT_RESET
            sudo apt install -y $PACKAGE_NAME
        else
            printf "already installed %s$PACKAGE_NAME%s." $FMT_CYAN $FMT_RESET
        fi
    elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        INSTALLED=$(dnf list installed $PACKAGE_NAME)
        if [ "$INSTALLED" == "" ]; then
            echo "installing %s$PACKAGE_NAME%s from dnf...\n" $FMT_CYAN $FMT_RESET
            sudo dnf install -y $PACKAGE_NAME
        else
            printf "already installed %s$PACKAGE_NAME%s." $FMT_CYAN $FMT_RESET
        fi
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
    FMT_PURPLE=$(printf '\033[35m')
    FMT_CYAN=$(printf '\033[36m')
    FMT_BOLD=$(printf '\033[1m')
    FMT_RESET=$(printf '\033[0m')
}

function wellcome () {
    printf "============================================================\n"
    printf "* %s$1%s\n" $FMT_PURPLE $FMT_RESET
    printf "============================================================\n"
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

wellcome "setting packages..."
for pack in "${PACKAGES[@]}"; do
    install_package $pack
done

wellcome "setting oh-my-zsh..."
if [ ! -d "/home/$USERNAME/.oh-my-zsh" ]; then
    printf "installing oh-my-zsh...\n"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    printf "already installed oh-my-zsh.\n"
fi

printf "getting jtriley custom theme...\n"
curl -fLos /home/$USERNAME/.oh-my-zsh/themes/jtriley-custom.zsh-theme https://raw.githubusercontent.com/luswdev/linux-user-defines/main/jtriley-custom.zsh-theme

wellcome "setting zsh..."
printf "changing shell to zsh...\n"
sudo chsh -s /bin/zsh "$USERNAME"

printf "getting zshrc...\n"
curl -sfLo /home/$USERNAME/.zshrc https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.zshrc

printf "getting dir color...\n"
curl -sfLo /home/$USERNAME/.dircolors https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.dircolors

printf "setting cache directory for zsh...\n"
mkdir -p /home/$USERNAME/.cache/zsh

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing zsh-autosuggestions...\n"
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    printf "already installed zsh-autosuggestions.\n"
fi

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing zsh-syntax-highlighting...\n"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
    printf "already installed zsh-syntax-highlighting.\n"
fi

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing you-should-use"
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git /home/$USERNAME/.oh-my-zsh/custom/plugins/you-should-use
else
    printf "already installed you-should-use.\n"
fi

install_package autojump

wellcome "seting vim..."
printf "getting vimrc...\n"
curl -sfLo /home/$USERNAME/.vimrc https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.vimrc

printf "installing vim-plug...\n"
curl -sfLo /home/$USERNAME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

printf "installing require vim plugs...\n"
vim -c 'PlugInstall' -c 'qall!'

printf "getting custom papercolor theme...\n"
curl -sfLo /home/$USERNAME/.vim/plugged/papercolor-theme/colors/PaperColor.vim https://raw.githubusercontent.com/luswdev/linux-user-defines/main/PaperColor.vim

wellcome "setting tmux..."
printf "getting tmux config...\n"
curl -sfLo /home/$USERNAME/.tmux.conf https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.tmux.conf

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ];
    printf "installing tmux-plugins: tpm"
    git clone https://github.com/tmux-plugins/tpm /home/$USERNAME/.tmux/plugins/tpm
else
    printf "already insatlled tmux-plugins: tpm"
fi

setup_color

printf "\n"
printf "\t %s o8o  %s            %s o8o  %s    .        %s      .o8  %s          %s            %s          %s\n"          $FMT_RAINBOW $FMT_RESET
printf "\t %s \`\"'  %s            %s \`\"'  %s  .o8        %s     \"888  %s          %s            %s          %s\n"     $FMT_RAINBOW $FMT_RESET
printf "\t %soooo  %sooo. .oo.   %soooo  %s.o888oo      %s .oooo888  %s .ooooo.  %sooo. .oo.   %s .ooooo.  %s\n"          $FMT_RAINBOW $FMT_RESET
printf "\t %s\`888  %s\`888P\"Y88b  %s\`888  %s  888        %sd88' \`888  %sd88' \`88b %s\`888P\"Y88b  %sd88' \`88b %s\n" $FMT_RAINBOW $FMT_RESET
printf "\t %s 888  %s 888   888  %s 888  %s  888        %s888   888  %s888   888 %s 888   888  %s888ooo888 %s\n"          $FMT_RAINBOW $FMT_RESET
printf "\t %s 888  %s 888   888  %s 888  %s  888 .      %s888   888  %s888   888 %s 888   888  %s888    .o %s\n"          $FMT_RAINBOW $FMT_RESET
printf "\t %so888o %so888o o888o %so888o %s  \"888\"      %s\`Y8bod88P\" %s\`Y8bod8P' %so888o o888o %s\`Y8bod8P' %s\n"    $FMT_RAINBOW $FMT_RESET
printf "\n"                                                

printf "run \"%ssource /home/$USERNAME/.zshrc%s\" manually to initial zsh\n"           $FMT_YELLOW $FMT_RESET
printf "run \"%stmux source /home/$USERNAME/.tmux.conf%s\" manually to initial tmux\n" $FMT_YELLOW $FMT_RESET

