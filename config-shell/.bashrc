# .bashrc

#zsh
#if [ -t 1 ]; then
#  exec zsh
#fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path to your installation.
export PATH="$HOME/.local/bin:$PATH"

# Path to my scripts
export PATH="$HOME/Proyectos/sh/scripts:$PATH"

# Rust
#source $HOME/.cargo/env

# Flutter
export PATH="$HOME/Developer/flutter/bin:$PATH"

# Android SDK
export ANDROID_SDK_ROOT="$HOME/Developer/android-sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"

# Chorme for flutter
#export CHROME_EXECUTABLE=/usr/bin/chromium
export CHROME_EXECUTABLE=/usr/bin/firefox

# Usar Java 17 para Flutter
export JAVA_HOME=/usr/lib/jvm/openjdk17
export PATH=$JAVA_HOME/bin:$PATH

alias saved='source .bashrc'
alias ls='ls -C -a -w1'
alias cls='clear'
alias install='sudo xbps-install'
alias remove='sudo xbps-remove'
alias update='sudo xbps-install -Syu'

PS1='[\u@\h \W]\$ '

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
