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

## sweet vim setup (WIP)

So, the files are in this repo but there is no sort of setup. I was planning on making one, but since starting this repo I have made a large change in how i roll my vim configs, now that i'm getting more familiar with neovim. 

Right now, my neovim `init.vim` basically tells neovim to look at `~/.vim/vimrc`, and then neovim more or less runs like vim. 

I'm still sort of wrapping my head around neovim's Lua scripting, and one thing I have realized is that I'm going to have to get used to the way neovim handles configurations and plugins, which means I will likely have to put all of this on hold. 

I still recommend checking out my vimrc though! You'll need to get vim-plugged installed, and then you can copy `vimrc` to `$HOME/.vim`. Run vim, ignore any errors that pop up immediately, and run `:PlugInstall` to automatically install the required plugins. Exit and reopen vim and voila!

## custom .zshrc **REQUIRES OH-MY-ZSH!**

The goal of my zshrc file through the years has been to make it as painless as possible to throw the exact same rc file on a variety of environments, so it trades a little heft (~7k) for **alot** of functionality. 

### automatic eyecandy 

The shellrc file checks for and installs a variety of useful eyecandy, such as my custom theme: 
~~~
if [[ $ZSH_THEME == "jerome" ]] && [[ ! -d "$ZSH/custom/themes/jerome-theme" ]]; then 
  git clone https://github.com/jeromescuggs/jerome-theme $ZSH/custom/themes/jerome-theme
  ln -sf $ZSH/custom/themes/jerome-theme/jerome.zsh-theme $ZSH/custom/themes
fi
~~~

Base16 terminal themes are also supported, but disabled by default: 
~~~
# to use this, uncomment the following: 
#
# export USE_BASE16
#
# check for base16 and set up if USE_BASE16 is set to "true"

if [ -v $USE_BASE16 ] && [ ! -d "$HOME/.config/base16-shell/" ]; then
     git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
   fi

if [ -v $USE_BASE16 ]; then
  BASE16_SHELL="$HOME/.config/base16-shell/"
  [ -n "$PS1" ] && \
  [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
  eval "$("$BASE16_SHELL/profile_helper.sh")"
fi
~~~

And probably the most useful: ZSH syntax highlighting! This is probably the one oh-my-zsh plugin that I cannot live without. 

~~~
 if [ -d "$HOME/.local" ] && [ -d "$HOME/.local/zsh-syntax-highlighting" ]; then
    source $HOME/.local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  else 
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.local/zsh-syntax-highlighting &&
    source $HOME/.local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
 fi
~~~

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
