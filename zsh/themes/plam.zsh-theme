#use extended color palette if available
if [[ $terminfo[colors] -ge 256 ]]; then
    turquoise="%F{81}"
    tangerine="%F{166}"
    orange="%F{214}"
    purple="%F{105}"
    violet="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
    green="%F{078}"
    gray="%F{237}"
    blue="%F{032}"
    red="%F{red}"
else
    turquoise="%F{cyan}"
    tangerine="%F{yellow}"
    orange="%F{yellow}"
    purple="%F{magenta}"
    violet="%F{magenta}"
    hotpink="%F{red}"
    limegreen="%F{green}"
    green="%F{green}"
    gray="%F{white}"
    blue="%F{blue}"
    red="%F{red}"
fi

PR_RST="%f"

# settings
typeset +H return_code="%(?..%{$red%}%? ↵%{$PR_RST%})"

# separator dashes size
function dashed_line {
    [[ -n "${VIRTUAL_ENV-}" && -z "${VIRTUAL_ENV_DISABLE_PROMPT-}" && "$PS1" = \(* ]] \
        && echo $(( COLUMNS - ${#VIRTUAL_ENV} - 3 )) \
        || echo $COLUMNS
}

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$orange%}*${PR_RST}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${PR_RST}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$green%} ✈"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%} ✭"
ZSH_THEME_GIT_PROMPT_DELETED="%{$red%} ✗"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%} ➦"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%} ✂"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$gray%} ✱"

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX="%{$gray%}["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"

# primary prompt - разделительная линия + чистый промпт на новой строке
PS1='%{$gray%}${(l.$(dashed_line)..-.)}${PR_RST}
${PR_RST}'

# Prompt when the last command was unsuccessful
PS2='%{$red%}\ ${PR_RST}'

# comprehensive right prompt with all information
RPS1='${return_code}'

# Add virtualenv info if available
(( $+functions[virtualenv_prompt_info] )) && RPS1+='$(virtualenv_prompt_info)'

# Add git info
RPS1+='%{$turquoise%}$(git_prompt_info)${PR_RST}'

# Add current directory
RPS1+=' %{$blue%}%~${PR_RST}'

# Add user and time
RPS1+=' %{$gray%}%n %T%{$reset_color%}'
