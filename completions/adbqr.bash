# Bash completion for adbqr

_adbqr_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-w --wizard -p --pair -c --connect -s --screen -u --usb -m --manual -l --list -d --diag -r --reset -t --timeout -h --help"

    case "$prev" in
        -t|--timeout)
            mapfile -t COMPREPLY < <(compgen -W "10 30 60 120" -- "$cur")
            return 0
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
        return 0
    fi
}

complete -F _adbqr_completions adbqr

