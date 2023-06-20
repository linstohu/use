ZSH_THEME="robbyrussell"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(
git
zsh-autosuggestions
zsh-syntax-highlighting
)

# https://ohmyz.sh/
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

zstyle ':omz:update' mode disabled  # disable automatic updates