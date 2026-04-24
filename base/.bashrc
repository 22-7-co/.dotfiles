#
# ~/.bashrc
#

alias ls='ls --color=auto'
alias grep='grep --color=auto'
set PS1 '[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$PATH"
export PATH=$HOME/.local/bin:$PATH

export HF_ENDPOINT=https://hf-mirror.com

# 设置默认使用系统剪贴板
set clipboard unnamedplus

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/22-7/.lmstudio/bin"
. "$HOME/.cargo/env"



# iNiR environment
export INIR_VENV="/home/22-7/.local/state/quickshell/.venv"
export ILLOGICAL_IMPULSE_VIRTUAL_ENV="$INIR_VENV"
# Apply terminal color sequences (Material You from wallpaper)
if [ -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt ]; then
  cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
fi
# end iNiR

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<






# iNiR launcher PATH
case ":$PATH:" in
  *:"/home/22-7/.local/bin":*) ;;
  *) export PATH="/home/22-7/.local/bin:$PATH" ;;
esac
# end iNiR launcher PATH

