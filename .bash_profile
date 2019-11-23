# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

# if [ -n "$force_color_prompt" ]; then
#     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# 	# We have color support; assume it's compliant with Ecma-48
# 	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# 	# a case would tend to support setf rather than setaf.)
# 	color_prompt=yes
#     else
# 	color_prompt=
#     fi
# fi

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(__git_ps1 "(%s)")\$ ' 
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# # If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi


set_prompts() {

    local black="" blue="" bold="" cyan="" green="" orange="" \
          purple="" red="" reset="" white="" yellow=""

    local dateCmd=""

    if [ -x /usr/bin/tput ] && tput setaf 1 &> /dev/null; then

        tput sgr0 # Reset colors

        bold=$(tput bold)
        reset=$(tput sgr0)

        # Solarized colors
        # (https://github.com/altercation/solarized/tree/master/iterm2-colors-solarized#the-values)
        black=$(tput setaf 0)
        blue=$(tput setaf 33)
        cyan=$(tput setaf 37)
        green=$(tput setaf 190)
        orange=$(tput setaf 172)
        purple=$(tput setaf 141)
        red=$(tput setaf 124)
        violet=$(tput setaf 61)
        magenta=$(tput setaf 9)
        white=$(tput setaf 8)
        yellow=$(tput setaf 136)

    else

        bold=""
        reset="\e[0m"

        black="\e[1;30m"
        blue="\e[1;34m"
        cyan="\e[1;36m"
        green="\e[1;32m"
        orange="\e[1;33m"
        purple="\e[1;35m"
        red="\e[1;31m"
        magenta="\e[1;31m"
        violet="\e[1;35m"
        white="\e[1;37m"
        yellow="\e[1;33m"

    fi

    # Only show username/host if not default
    function usernamehost() {
        
        # Highlight the user name when logged in as root.
        if [[ "${USER}" == *"root" ]]; then
            userStyle="${red}";
        else
            userStyle="${green}";
        fi;

        userhost=""
        userhost+="\[${userStyle}\]$USER "
        userhost+="${white}at "
        userhost+="${violet}$HOSTNAME "
        userhost+="${white}in"

        if [ $USER != "$default_username" ]; then echo $userhost ""; fi
    }


    function prompt_git() {
        # this is >5x faster than mathias's. has to be for working in Chromium & Blink.

        # check if we're in a git repo. (fast)
        git rev-parse --is-inside-work-tree &>/dev/null || return

        # check for what branch we're on. (fast)
        # If HEAD isnâ€™t a symbolic ref, get the short SHA for the latest commit
        # Otherwise, just give up.
        branchName="$(git rev-parse --abbrev-ref HEAD 2> /dev/null || \
            git symbolic-ref --quiet --short HEAD 2> /dev/null || \
            git rev-parse --short HEAD 2> /dev/null || \
            echo '(unknown)')";

        # branchName = '$(__git_ps1 "(%s)")';


        ## early exit for Chromium & Blink repo, as the dirty check takes ~5s
        repoUrl=$(git config --get remote.origin.url)
        if grep -q chromium.googlesource.com <<<$repoUrl; then
            dirty=" â‚"
        else

            # check if it's dirty (slow)
            #   technique via github.com/git/git/blob/355d4e173/contrib/completion/git-prompt.sh#L472-L475
            dirty=$(git diff --no-ext-diff --quiet --ignore-submodules --exit-code || echo -e "*")

            # mathias has a few more checks some may like:
            #    github.com/mathiasbynens/dotfiles/blob/a8bd0d4300/.bash_prompt#L30-L43
        fi


        [ -n "${s}" ] && s=" [${s}]";
        echo -e "${1}${branchName}${2}$dirty";

        return
    }



    # ------------------------------------------------------------------
    # | Prompt string                                                  |
    # ------------------------------------------------------------------

    PS1="\[\033]0;\w\007\]"                                 # terminal title (set to the current working directory)
    PS1+="\[$bold\]"
    PS1+="\[$(usernamehost)\]"                              # username at host
    PS1+="\[$green\]\w"                                     # working directory 
    PS1+="\$(prompt_git \"$white on $purple\" \"$cyan\")"   # git repository details
    PS1+="\n"
    PS1+="\[$reset$white\]\\$ \[$reset\]"

    export PS1

    # ------------------------------------------------------------------
    # | Subshell prompt string                                         |
    # ------------------------------------------------------------------

    PS2="âš¡ "

    export PS2

    # ------------------------------------------------------------------
    # | Debug prompt string                                            |
    # ------------------------------------------------------------------

    # e.g:
    #
    # The GNU `date` command has the `%N` interpreted sequence while
    # other implementations don't (on OS X `gdate` can be used instead
    # of the native `date` if the `coreutils` package was installed)
    #
    # if [ "$(date +%N)" != "N" ] || \
    #    [ ! -x "$(command -v 'gdate')" ]; then
    #    dateCmd="date +%s.%N"
    # else
    #    dateCmd="gdate +%s.%N"
    # fi
    #
    # PS4="+$( tput cr && tput cuf 6 &&
    #          printf "$yellow %s $green%6s $reset" "$($dateCmd)" "[$LINENO]" )"
    #
    # PS4 output:
    #
    #   ++    1357074705.875970000  [123] '[' 1 == 0 ']'
    #   â””â”€â”€â”¬â”€â”˜â””â”€â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”¬â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜
    #      â”‚       â”‚         â”‚        â”‚          â”‚
    #      â”‚       â”‚         â”‚        â”‚          â””â”€ command
    #      â”‚       â”‚         â”‚        â””â”€ line number
    #      â”‚       â”‚         â””â”€ nanoseconds
    #      â”‚       â””â”€ seconds since 1970-01-01 00:00:00 UTC
    #      â””â”€ depth-level of the subshell

    PS4="+$( tput cr && tput cuf 6 && printf "%s $reset" )"

    export PS4

}



set_prompts
unset set_prompts



# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# custom aliases for mEEE
alias gs='git status'
alias gc='git commit -a -m'

# Add this if you need mac shorcuts
# xmodmap ~/.xmodmaprc

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
export PATH=$HOME/local/bin:$PATH

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export GOPATH=$HOME/Projects/GoRelatedexport PATH=$HOME/local/bin:$PATH

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

export PATH="$HOME/.yarn/bin:$PATH"

# add ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"

