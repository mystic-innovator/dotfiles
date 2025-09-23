# FILE AUTOMATICALLY GENERATED FROM /home/kashif/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]] zimfw() { source "${HOME}/.zim/zimfw.zsh" "${@}" }
fpath=("${HOME}/.zim/modules/utility/functions" "${HOME}/.zim/modules/completion/functions" "${HOME}/.zim/modules/git/functions" ${fpath})
autoload -Uz -- mkcd mkpw git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove
source "${HOME}/.zim/modules/environment/init.zsh"
source "${HOME}/.zim/modules/utility/init.zsh"
source "${HOME}/.zim/modules/completion/init.zsh"
source "${HOME}/.zim/modules/git/init.zsh"
source "${HOME}/.zim/modules/input/init.zsh"
source "${HOME}/.zim/modules/termtitle/init.zsh"
source "${HOME}/.zim/modules/zsh-completions/zsh-completions.plugin.zsh"
source "${HOME}/.zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${HOME}/.zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
