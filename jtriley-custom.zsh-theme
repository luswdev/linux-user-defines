PROMPT='
%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})• %{$fg_bold[cyan]%}%T%{$fg_bold[green]%} [%h] %{$fg_bold[white]%}%n%{$fg[magenta]%}@%{$fg_bold[white]%}%M %{$fg_bold[green]%}%~ %{$fg_bold[yellow]%}$(git_prompt_info)
%{$fg_bold[yellow]%}$ %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
