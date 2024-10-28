#!/bin/bash

USERNAME="$(whoami)"

function install_package () {
    PACKAGE_NAME=$1
    if [ -f /etc/debian_version ]; then
        INSTALLED=$(apt list --installed 2>&1 | grep $PACKAGE_NAME)
        IS_VALID=$(apt-cache show $PACKAGE_NAME 2>&1)
        if [ "$IS_VALID" == "E: No packages found" ]; then
            printf "skipped %s$PACKAGE_NAME%s for apt.\n" $FMT_CYAN $FMT_RESET
        elif [ "$INSTALLED" == "" ]; then
            printf "installing %s$PACKAGE_NAME%s from apt...\n" $FMT_CYAN $FMT_RESET
            sudo apt install -y $PACKAGE_NAME
        else
            printf "already installed %s$PACKAGE_NAME%s.\n" $FMT_CYAN $FMT_RESET
        fi
    elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        INSTALLED=$(dnf list installed $PACKAGE_NAME 2>&1)
        IS_VALID=$(dnf info $PACKAGE_NAME 2>&1)
        if [[ "$IS_VALID" == *"Error: No matching Packages to list"* ]]; then
            printf "skipped %s$PACKAGE_NAME%s for dnf.\n" $FMT_CYAN $FMT_RESET
        elif [ "$INSTALLED" == "" ]; then
            printf "installing %s$PACKAGE_NAME%s from dnf...\n" $FMT_CYAN $FMT_RESET
            sudo dnf install -y $PACKAGE_NAME
        else
            printf "already installed %s$PACKAGE_NAME%s.\n" $FMT_CYAN $FMT_RESET
        fi
    else
        echo "unsupported OS distribution. please manually install package: %s$PACKAGE_NAME%s\n" $FMT_CYAN $FMT_RESET
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
    printf "\n"
    printf "============================================================\n"
    printf "* setting %s$1%s...\n" $FMT_PURPLE $FMT_RESET
    printf "============================================================\n"
    printf "\n"
}

PACKAGES=(
    git
    make
    automake
    gcc
    gcc-c++
    g++
    kernel-devel
    linux-headers-generic
    vim
    tmux
    zsh
    fzf
)

setup_color

wellcome "packages"
for pack in "${PACKAGES[@]}"; do
    install_package $pack
done

wellcome "oh-my-zsh"
if [ ! -d "/home/$USERNAME/.oh-my-zsh" ]; then
    printf "installing %soh-my-zsh%s...\n" $FMT_CYAN $FMT_RESET
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    printf "already installed %soh-my-zsh%s.\n" $FMT_CYAN $FMT_RESET
fi

printf "getting jtriley custom theme...\n"
curl -sfLo /home/$USERNAME/.oh-my-zsh/themes/jtriley-custom.zsh-theme https://raw.githubusercontent.com/luswdev/linux-user-defines/main/jtriley-custom.zsh-theme

wellcome "zsh"
printf "changing shell to zsh...\n"
sudo chsh -s $(which zsh) $USERNAME

printf "getting %szshrc%s...\n" $FMT_CYAN $FMT_RESET
curl -sfLo /home/$USERNAME/.zshrc https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.zshrc

printf "getting %sdircolors%s...\n" $FMT_CYAN $FMT_RESET
curl -sfLo /home/$USERNAME/.dircolors https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.dircolors

printf "setting cache directory for zsh...\n"
mkdir -p /home/$USERNAME/.cache/zsh

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing %szsh-autosuggestions%s...\n" $FMT_CYAN $FMT_RESET
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    printf "already installed %szsh-autosuggestions%s.\n" $FMT_CYAN $FMT_RESET
fi

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing %szsh-syntax-highlighting%s...\n" $FMT_CYAN $FMT_RESET
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
    printf "already installed %szsh-syntax-highlighting%s.\n" $FMT_CYAN $FMT_RESET
fi

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing %syou-should-use%s\n" $FMT_CYAN $FMT_RESET
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git /home/$USERNAME/.oh-my-zsh/custom/plugins/you-should-use
else
    printf "already installed %syou-should-use%s.\n" $FMT_CYAN $FMT_RESET
fi

install_package autojump

wellcome "vim"
printf "getting %svimrc%s...\n" $FMT_CYAN $FMT_RESET
curl -sfLo /home/$USERNAME/.vimrc https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.vimrc

printf "installing %svim-plug%s...\n" $FMT_CYAN $FMT_RESET
curl -sfLo /home/$USERNAME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

printf "installing require %svim plugs%s...\n" $FMT_CYAN $FMT_RESET
vim -c 'PlugInstall' -c 'qall!'

printf "getting custom papercolor theme...\n"
curl -sfLo /home/$USERNAME/.vim/plugged/papercolor-theme/colors/PaperColor.vim https://raw.githubusercontent.com/luswdev/linux-user-defines/main/PaperColor.vim

printf "getting airline custom theme...\n"
curl -sfLo /home/$USERNAME/.vim/plugged/vim-airline-themes/autoload/airline/themes/minimalist.vim https://raw.githubusercontent.com/luswdev/linux-user-defines/main/minimalist.vim

wellcome "tmux"
printf "getting tmux config...\n"
curl -sfLo /home/$USERNAME/.tmux.conf https://raw.githubusercontent.com/luswdev/linux-user-defines/main/.tmux.conf

if [ ! -d /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    printf "installing tmux-plugins: %stpm%s\n" $FMT_CYAN $FMT_RESET
    git clone https://github.com/tmux-plugins/tpm /home/$USERNAME/.tmux/plugins/tpm
else
    printf "already insatlled tmux-plugins: %stpm%s\n" $FMT_CYAN $FMT_RESET
fi

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

