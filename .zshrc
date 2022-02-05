# set omz install path, set path for rustup completions
export ZSH="/home/$USER/.oh-my-zsh"
fpath+=~/.zfunc

# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end

# if starship is installed, setting this flag to "true"
# will override all themes except 'zeta'. 
# this saves a trip to the bottom of this rc file to manually change it.
RUN_STARSHIP="false"
# jerome-theme can be found at github.com/jeromescuggs/jerome-theme
#ZSH_THEME="zeta"
ZSH_THEME="jerome"
#ZSH_THEME="dieter"

# TODO condition this on finding a dietpi-exclusive executable 
if [[ -d /DietPi ]]; then
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:$PATH
/DietPi/dietpi/dietpi-login
. /DietPi/dietpi/func/dietpi-globals 
fi 

if [[ -d $HOME/.deno ]]; then 
    export DENO_INSTALL="/home/jerome/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi 

# uncomment the following code when using liquidprompt - must be installed first!
# [[ $- = *i* ]] && source ~/liquidprompt/liquidprompt

# purely aesthetic, comment the following out if troubleshooting, but it shouldn't cause any issues
COMPLETION_WAITING_DOTS="true"

# base16 shell colorthemes: type "base16" in prompt and mash dat mf tab button
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
         eval "$("$BASE16_SHELL/profile_helper.sh")"

# check to see if the base16-shell default installation is present, and grab it if it isn't

 if [ -d "$HOME/.config/base16-shell/" ]; then
    export BASE16_INSTALLED="1"
 else 
     git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
   fi

# Uncomment the following when working with large VCS (git etc) repo's, and experience lag when moving thru directories
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*

if [[ -x "$(command -v keychain)" ]]; then
plugins=(
        zsh-256color
        sudo	
        )
else
plugins=(
        zsh-256color
        sudo
		ssh-agent
        )
fi

# other popular plugins:
# git, debian, ubuntu, ssh-agent, gpg-agent, tmux

# try to minimize any more code above this line - the following
# initiliazes the meat of oh-my-zsh, and everything below it is executed 
# "within the context" of the OMZ environment
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"
export COLORTERM="truecolor"

# You may need to manually set your language environment
# NOTE: i've read reports that LANG is supposed to be set as "en" and not 
# used to define the character set, ie, unicode 
# if you still have hiccups, try setting the bottom variable instead 
# export LANG="en_US.UTF-8"
# export LANG="en"
export LC_ALL="en_US.UTF-8"


# WSL1 compatibility with X server (x410, others should work)
if [[ "$(</proc/version)" == *Microsoft* ]] 2>/dev/null; then
  export WSL=1
  export DISPLAY=localhost:0
  export NO_AT_BRIDGE=1
  export LIBGL_ALWAYS_INDIRECT=1
#  sudo /usr/local/bin/clean-tmp-su
# else
# export WSL=0
fi

# WSL compatibility
if [[ "$(</proc/version)" == *microsoft* ]] 2>/dev/null; then
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
export LIBGL_ALWAYS_INDIRECT
fi 

# check for a .local dir in $HOME and make one if absent 

if [[ ! -d "$HOME/.local" ]]; then
  mkdir $HOME/.local 
fi 

# Rust/cargo PATH
export PATH="$PATH:/home/jerome/.cargo/bin"

# pip path
export PATH="$PATH:/home/jerome/.local/bin"

# Go path, not nearly as important now that GO111MODULE is a thing
# if [[ -x "$(command -v go)" ]]; then
if [[ -d /usr/local/go/bin ]]; then
    export GOPATH=$HOME/go
    export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
fi

# personal bin
if [[ -d $HOME/.jrmbin ]]; then
    export PATH="$PATH:/home/$USER/.jrmbin"
fi

# notes dir
if [[ -a /usr/local/bin/notes ]]; then
  export NOTES_DIRECTORY="$HOME/.notes"
fi 

if [[ -d $HOME/balena-cli ]]; then
    export PATH="$PATH:/home/$USER/balena-cli"
fi

# RVM - define PATH and source as a function 
if [[ -d $HOME/.rvm ]]; then
    export PATH="$PATH:$HOME/.rvm/bin"
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
fi 

# rbenv - define PATH and source rbenv 
if [[ -d $HOME/.rbenv ]]; then 
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi 

# toolchains
export PATH="$PATH:$(find . /opt -maxdepth 1 -user jerome -type d -name '*gcc*')"

# this variable can be tweaked to get a variety of things to play nice. default is set to 24bit to 
# make the best of the pastel utility
export COLORTERM=24bit 

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
# else
#   export EDITOR='nvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"


if [[ -x "$(command -v brew)" ]]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if [[ -x "$(command -v keychain)" ]]; then
    eval `keychain --eval --agents ssh,gpg id_rsa 04DF830B7F2373C7`
fi

# eyecandy: the following defines colorschemes for the 'ls' command and its relatives 
# depending on things, calling one, both, one before the other, etc. can lead to different blends of colors, so i'm leaving it all below

export LS_COLORS="$(vivid generate snazzy)"

# eval $(dircolors -b $HOME/.dircolors)

# eval $(dircolors -b $HOME/.dircolors)
 if [ -n "$LS_COLORS" ]; then
       zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
 fi

 if [[ -x "$(command -v vivid)" ]]; then
    export LS_COLORS="$(vivid generate snazzy)"
 fi 

# eval $(TERM=xterm-256color dircolors ~/.dircolors)

# invoke tmux requirements 
if 
  [ -z $TMUX ] 
then
    export TERM=xterm-256color
  else 
    export TERM=tmux-256color
fi

# banner: the following is what pops up upon initial login
# cfonts jerome -c cyan,candy -s 

source ~/.aliases

 if [ -d "$HOME/.local" ] && [ -d "$HOME/.local/zsh-syntax-highlighting" ]; then
    source $HOME/.local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  else 
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.local/zsh-syntax-highlighting &&
    source $HOME/.local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
 fi



# initialize zsh-syntax-highlighting
source /home/$USER/.dotfiles/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 

# TODO: check for starship, if true, execute: 
if [[ $RUN_STARSHIP == "true" ]] && [[ -f $HOME/.cargo/bin/starship ]] && [[ $ZSH_THEME != "zeta" ]]; then
    eval "$(starship init zsh)"
fi 
# export TERM="xterm-256color"

compinit

if [[ -f $HOME/.cargo/bin/broot ]]; then
    source /home/jerome/.config/broot/launcher/bash/br
fi 

if [[ -d $HOME/.resh ]]; then
    [ -f ~/.resh/shellrc ] && source ~/.resh/shellrc
fi 

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/jerome/.sdkman"
[[ -s "/home/jerome/.sdkman/bin/sdkman-init.sh" ]] && source "/home/jerome/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
