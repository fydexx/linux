###

# Set Defaults
export EDITOR="vim"
#export BROWSER="firefox"
export BROWSER="google-chrome"
export HISTCONTROL="ignoredups"

# grep options
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

# ls colors
autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"

setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt auto_cd
setopt multios
setopt cdablevarS
setopt prompt_subst

PS1="%n@%m:%~%# "
SHORT_HOST=${HOST/.*/}
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
autoload -U compinit
compinit -i -d "${ZSH_COMPDUMP}"

# Colors
export NC='\e[0m'
export white='\e[0;30m'
export WHITE='\e[1;30m'
export red='\e[0;31m'
export RED='\e[1;31m'
export green='\e[0;32m'
export GREEN='\e[1;32m'
export yellow='\e[0;33m'
export YELLOW='\e[1;33m'
export blue='\e[0;34m'
export BLUE='\e[1;34m'
export magenta='\e[0;35m'
export MAGENTA='\e[1;35m'
export cyan='\e[0;36m'
export CYAN='\e[1;36m'
export black='\e[0;37m'
export BLACK='\e[1;37m'

# Colorful manpages using less
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'

# autocorrection
setopt correct_all
alias man='nocorrect man'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias mkdir='nocorrect mkdir'
alias gist='nocorrect gist'
alias heroku='nocorrect heroku'
alias ebuild='nocorrect ebuild'
alias hpodder='nocorrect hpodder'
alias sudo='nocorrect sudo'

## Command history configuration
if [ -z $HISTFILE ]; then
    HISTFILE=$HOME/.zsh_history
fi
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data

# Set Aliases
alias update='yaourt -Syu'
alias clean='sudo sh ~/scripts/pacclean.sh'
alias mem='free -mot; sync && echo -n 3 | sudo tee /proc/sys/vm/drop_caches; free -mot'
alias diff='colordiff'
alias xorg='sudo subl /etc/X11/xorg.conf'
alias nano='nano -w'
alias ls='ls -hF --color=auto --group-directories-first '
alias df='df -h -T'
alias grep='grep -n --color=auto'
alias duf='du -skh * | sort -n'
# quick nmap scan over socks
alias pscan='proxychains nmap -sTV -PN -n -p21,22,25,80,3306,6667 '
# http server for testing static content
alias http='python2 -m SimpleHTTPServer 8080'
# minify style.css using cssutils from python
alias cssminify='cssparse -m style.css > style.min.css'
# start chrome with custom user without proxy for localhost testing (default setup but with livereload installed)
alias chromel='google-chrome --user-data-dir=$HOME/www/chrome_dev --no-proxy-server'

# Extract
function extract () {
    if [ -f $1 ] ; then
case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.tar.xz) tar xJf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
else
echo "'$1' is not a valid file"
    fi
}

# Set path
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/bin:/opt/dassault-systemes/draftsight/bin:/usr/bin/vendor_perl:/usr/bin/core_perl:~/.gem/ruby/2.0.0/bin:/opt/android-sdk/platform-tools

# archlinux specific Aliases

function paclist() {
  sudo pacman -Qei $(pacman -Qu|cut -d" " -f 1)|awk ' BEGIN {FS=":"}/^Name/{printf("\033[1;36m%s\033[1;37m", $2)}/^Description/{print $2}'
}

alias paclsorphans='sudo pacman -Qdt'
alias pacrmorphans='sudo pacman -Rs $(pacman -Qtdq)'

function pacdisowned() {
  tmp=${TMPDIR-/tmp}/pacman-disowned-$UID-$$
  db=$tmp/db
  fs=$tmp/fs

  mkdir "$tmp"
  trap  'rm -rf "$tmp"' EXIT

  pacman -Qlq | sort -u > "$db"

  find /bin /etc /lib /sbin /usr \
      ! -name lost+found \
        \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

  comm -23 "$fs" "$db"
}

function pacmanallkeys() {
  # Get all keys for developers and trusted users
  curl https://www.archlinux.org/{developers,trustedusers}/ |
  awk -F\" '(/pgp.mit.edu/) {sub(/.*search=0x/,"");print $1}' |
  xargs sudo pacman-key --recv-keys
}

function pacmansignkeys() {
  for key in $*; do
    sudo pacman-key --recv-keys $key
    sudo pacman-key --lsign-key $key
    printf 'trust\n3\n' | sudo gpg --homedir /etc/pacman.d/gnupg \
      --no-permission-warning --command-fd 0 --edit-key $key
  done
}

### end archlinux specific

function title() {
    local access
    local cmd

    if [[ $USERNAME != $LOGNAME || -n $SSH_CLIENT ]]; then
        access="${USERNAME}@${HOST}: "
    fi

    if [[ $# -eq 0 ]]; then
        cmd="zsh %30<...<%~"
    else
        cmd="${(V)1//\%/\%\%}"
    fi

    case $TERM in
        rxvt*)
            print -Pn "\e]0;${access}${cmd}\e\\"
            ;;
        screen*)
            print -Pn "\ek${cmd}\e\\"
            print -Pn "\e_${access}\e\\"
            ;;
    esac
}

precmd_functions+='title'
preexec_functions+='title'

function zsh_stats() {
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

## smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

## file rename magick
bindkey "^[m" copy-prev-shell-word

## jobs
setopt long_list_jobs

## pager
export PAGER="less"
export LESS="-R"

export LC_CTYPE=$LANG

## custom theme - equk
function prompt_char {
  if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~)$(git_prompt_info)$(virtualenv_prompt_info)%{$fg_bold[blue]%}%_$(prompt_char)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX=" (%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗%{$fg[blue]%})%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔%{$fg[blue]%})%{$reset_color%}"

## virtualenv support for theme
function virtualenv_prompt_info(){
  if [[ -n $VIRTUAL_ENV ]]; then
    printf "%s[%s] " "%{${fg[yellow]}%}" ${${VIRTUAL_ENV}:t}
  fi
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1