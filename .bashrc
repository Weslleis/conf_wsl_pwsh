# ~/.bashrc: executado por bash para shells não-login.

# Locale / teclado
export LANGUAGE="pt_BR.UTF-8"
export LC_ALL="pt_BR.UTF-8"
export LC_CTYPE="pt_BR.UTF-8"
export LC_MESSAGES="pt_BR.UTF-8"
export LANG="pt_BR.UTF-8"

# Apenas define teclado se X estiver disponível
if command -v setxkbmap &> /dev/null && [ -n "$DISPLAY" ]; then
    setxkbmap -layout br
fi

#=======================================
# Oh My Posh: Configuração direta para Bash
# Aponta para o mesmo tema usado no PowerShell do Windows, acessível via WSL
if command -v oh-my-posh &> /dev/null; then
    # Caminho completo para o seu tema no sistema de ficheiros do Windows, acessível via WSL
    # Certifique-se de que este caminho corresponde ao seu tema atual no Windows.
    OH_MY_POSH_THEME_PATH="/mnt/c/Users/SeuNome/AppData/Local/Programs/oh-my-posh/themes/montys.omp.json"

    # Verifica se o ficheiro do tema existe antes de inicializar o Oh My Posh
    if [ -f "$OH_MY_POSH_THEME_PATH" ]; then
        eval "$(oh-my-posh init bash --config "$OH_MY_POSH_THEME_PATH")"
    else
        echo "Aviso: Tema Oh My Posh não encontrado em '$OH_MY_POSH_THEME_PATH'. O prompt padrão será usado." >&2
    fi
fi
#=======================================

# Não executa nada se não for shell interativo
case $- in
    *i*) ;;
      *) return;;
esac

# Histórico
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Ajuste de terminal
shopt -s checkwinsize

# Menos mais inteligente
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Nome do chroot
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Prompt de terminal (fallback) - Oh My Posh irá sobrescrever este se for carregado
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 &> /dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Título do terminal
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias úteis
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Notificação de comando longo
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Carregar aliases extras, se existirem
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Autocompletar comandos
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
