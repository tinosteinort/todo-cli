#!/usr/bin/env bash

_todo_completion() {
    local cur prev

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "init list add remove check  uncheck target help" -- ${cur}))
            ;;
        2)
            case ${prev} in
                list)
                    COMPREPLY=($(compgen -W "all open checked" -- ${cur}))
                    ;;
                target)
                    COMPREPLY=($(compgen -W "select list create delete" -- ${cur}))
                    ;;
            esac
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _todo_completion todo
