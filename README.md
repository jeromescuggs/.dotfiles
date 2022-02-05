# .dotfiles

Well, it's about time I got a grip on my personal dotfiles folder, which has only filled with bloat and tidbits of script that I've accumulated over the years. This is the WIP repo for my refreshed dots. 

## TODO
- **one-and-done setup script**
- aliases and .inputrc 
- ~~shell rc (zsh)~~
- oh-my-zsh plugins + install script 
- common dependencies install script 
- tmux configs 
- vim config 

# features

## custom .zshrc **REQUIRES OH-MY-ZSH!**

The goal of my zshrc file through the years has been to make it as painless as possible to throw the exact same rc file on a variety of environments, so it trades a little heft (~7k) for **alot** of functionality. 

### conditional env setup 

The rc file checks for a variety of common developer tools using conditionals. For example: 

~~~
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
~~~

Assuming the default install paths for RVM or rbenv, the shellrc will set the necessary variables and paths. 

Incomplete list of supported tools:
- Go 
- Cargo
- Rustup 
- n (npm version manager)
- pip/pip3 (python)

### platform-specific setup 

The shellrc will check to see if it is running on WSL1 or WSL2 and set the appropriate variables to allow connecting to a Windows-side X server like X410 or VcXsrv: 

~~~
# WSL1 compatibility with X server (x410, others should work)
if [[ "$(</proc/version)" == *Microsoft* ]] 2>/dev/null; then
  export WSL=1
  export DISPLAY=localhost:0
  export NO_AT_BRIDGE=1
  export LIBGL_ALWAYS_INDIRECT=1
fi

# WSL2 compatibility
if [[ "$(</proc/version)" == *microsoft* ]] 2>/dev/null; then
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
export LIBGL_ALWAYS_INDIRECT
fi
~~~

It will also detect if you're running on a DietPi box, and adjust accordingly to allow integration with DietPi-specific commands:

~~~
# check if running on a dietpi box and setup 
# TODO condition this on finding a dietpi-exclusive executable 
if [[ -d /DietPi ]]; then
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:$PATH
/DietPi/dietpi/dietpi-login
. /DietPi/dietpi/func/dietpi-globals 
fi
~~~

### app-specific setup 

A wide variety of popular programs also have conditionals allowing them to be integrated if they exist on your machine: 

~~~
# check for brew and set up
if [[ -x "$(command -v brew)" ]]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

# check for keychain and set up
if [[ -x "$(command -v keychain)" ]]; then
    eval `keychain --eval --agents ssh,gpg id_rsa`
fi

# check for vivid and set up LS_COLORS

 if [ -n "$LS_COLORS" ]; then
       zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
 fi

 if [[ -x "$(command -v vivid)" ]]; then
    export LS_COLORS="$(vivid generate snazzy)"
 fi 

# check for tmux requirements and set up
if 
  [ -z $TMUX ] 
then
    export TERM=xterm-256color
  else 
    export TERM=tmux-256color
fi

# ALIASES 
if [ -e $HOME/.aliases ]; then 
  source ~/.aliases
fi
~~~

You'll have to pore through the `.zshrc` file and see what all is in there. Apologies, but organizing all of the settings is not high on my list, and there is still alot more I have not yet covered in this readme! 
