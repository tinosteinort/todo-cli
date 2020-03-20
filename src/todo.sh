#!/usr/bin/env bash

set -e

CURRENT_DIR=$(pwd)

command="todo-$1"
commandParams="${@:2}"

TODO_FOLDER_NAME='.todo'
TODO_FILE_NAME='todo'
TARGET_FILE_NAME='.target'

function todo-help() {
    echo 'usage: todo <command> [<subcommand>] [<args>]'
    echo ''
    echo '  init                               Initialise a new TODO list in the current folder'
    echo '  list [all|open|checked]            Shows all tasks'
    echo '  add <task description>             Add a new task to the list'
    echo '  remove <number of task>            Remove a task by its number'
    echo '  check <number of task>             Resolve a task by its number'
    echo '  uncheck <number of task>           Reopen a task by its number'
    echo '  target select <target>             Select the TODO list with the specified name'
    echo '  target list                        Show all available target TODO lists'
    echo '  target create <target>             Add a new TODO list with the specified name'
    echo '  target delete <target>             Delete the TODO list with the specified name'
    echo '  help                               Show this help'
}

function alreadyToDoList() {
    echo "This place is already part of a TODO list:"
    echo "$1"
    exit 1
}

function noToDoList() {
    echo "This place is not part of a TODO list or the target TODO list does not exist"
    exit 1
}

function todo-init() {
    local todoListFile
    todoListFile="$TODO_FOLDER_NAME/$TODO_FILE_NAME"

    local targetFile
    targetFile="$TODO_FOLDER_NAME/$TARGET_FILE_NAME"

    if [ -d "$TODO_FOLDER_NAME" ]
    then
        if [ -e "$todoListFile" ]
        then
            alreadyToDoList "$(pwd)/$todoListFile"
        else
            touch "$todoListFile"
        fi
    else
        mkdir "$TODO_FOLDER_NAME"
        touch "$todoListFile"
        echo "$TODO_FILE_NAME" > "$targetFile"
    fi
}

function findToDoFolder() {
    local folder
    folder=$1

    cd "$folder"

    if [ -d "$TODO_FOLDER_NAME" ]
    then
        echo "$(pwd)/$TODO_FOLDER_NAME"
    else
        if [ "$folder" == "/" ]
        then
            echo "Folder not found"
            exit 1
        fi
        findToDoFolder "$(dirname "$folder")"
    fi
}

function findToDoListFolder() {
    cd "$CURRENT_DIR"

    local todoFolder
    todoFolder="$(findToDoFolder "$CURRENT_DIR")"

    cd "$CURRENT_DIR"
    echo "$todoFolder"
}

function toDoFile() {
    local folder
    folder=$(findToDoListFolder)

    local targetFile
    targetFile="$folder/$TARGET_FILE_NAME"

    if [ -f "$targetFile" ]
    then
        local target
        target=$(<"$targetFile")
    fi

    local todoFile
    todoFile="$folder/$target"

    if [ -z "$target" ] || [ ! -e "$todoFile" ]
    then
        echo ""
    fi

    echo "$todoFile"
}

function todo-add() {
    local allCommandParams
    allCommandParams="$*"

    local todoListFile
    todoListFile=$(toDoFile)

    if [ -e "$todoListFile" ]
    then
        echo "[ ] $allCommandParams" >> "$todoListFile"
    else
        noToDoList
    fi
}

function todo-list() {
    local type
    type=$1

    local todoListFile
    todoListFile=$(toDoFile)

    if [ -e "$todoListFile" ]
    then
        echo "Target TODO list: $(basename "$todoListFile")"

        local lineNumber
        lineNumber=0

        while read line
        do
            if [ "${line:0:3}" == '[ ]' ] && [ "$type" == "open" ]
            then
                lineNumber=$(($lineNumber+1))
                echo "$lineNumber: $line"
            elif [ "${line:0:3}" == "[X]" ] && [ "$type" == "checked" ]
            then
                lineNumber=$(($lineNumber+1))
                echo "$lineNumber: $line"
            elif [ "$type" == "all" ] || [ -z "$type" ]
            then
                lineNumber=$(($lineNumber+1))
                echo "$lineNumber: $line"
            fi
        done < "$todoListFile"
    else
        noToDoList
    fi
}

function transform() {
    local command
    command=$1

    local taskNumber
    taskNumber=$2

    local todoListFile
    todoListFile=$(toDoFile)

    local todoListFileTemp
    todoListFileTemp="$todoListFile.temp"

    if [ -e "$todoListFile" ]
    then
        local lineNumber
        lineNumber=1
        while read line
        do
            if [ "$taskNumber" == "$lineNumber" ] && [ "${line:0:3}" == '[ ]' ] && [ "$command" == "check" ]
            then
                echo "$line" | sed -e 's/^\[\s\]\s/[X] /' >> "$todoListFileTemp"
                lineNumber=$(($lineNumber+1))
            elif [ "$taskNumber" == "$lineNumber" ] && [ "${line:0:3}" == "[X]" ] && [ "$command" == "uncheck" ]
            then
                echo "$line" | sed -e 's/^\[X\]\s/\[ \] /' >> "$todoListFileTemp"
                lineNumber=$(($lineNumber+1))
            elif [ "$taskNumber" == "$lineNumber" ] && [ "$command" == "remove" ]
            then
                lineNumber=$(($lineNumber+1))
            else
                echo "$line" >> "$todoListFileTemp"
                lineNumber=$(($lineNumber+1))
            fi
        done < "$todoListFile"

        rm "$todoListFile"
        mv "$todoListFileTemp" "$todoListFile"
    else
        noToDoList
    fi
}

function todo-check() {
    local taskNumber
    taskNumber=$1

    transform "check" "$taskNumber"
}

function todo-uncheck() {
    local taskNumber
    taskNumber=$1

    transform "uncheck" "$taskNumber"
}

function todo-remove() {
    local taskNumber
    taskNumber=$1

    transform "remove" "$taskNumber"
}

function todo-target-select() {
    local targetListName
    targetListName=$1

    local folder
    folder=$(findToDoListFolder)

    local targetFile
    targetFile="$folder/$TARGET_FILE_NAME"

    local todoListFile
    todoListFile="$folder/$targetListName"


    if [ "$targetListName" == "$TARGET_FILE_NAME" ]
    then
        echo "Name '$targetListName' not allowed as target"
        exit 1
    elif [ ! -f "$todoListFile" ]
    then
        echo "TODO list '$targetListName' does not exist"
        exit 1
    fi

    echo "$targetListName" > "$targetFile"
}

function todo-target-list() {
    local folder
    folder=$(findToDoListFolder)

    local files
    files=(${folder}/*)

    for f in "${files[@]}";
    do
        echo $(basename "$f")
    done
}

function todo-target-create() {
    local targetListName
    targetListName=$1

    local folder
    folder=$(findToDoListFolder)

    local targetFile
    targetFile="$folder/$TARGET_FILE_NAME"

    local todoListFile
    todoListFile="$folder/$targetListName"


    if [ "$targetListName" == "$TARGET_FILE_NAME" ]
    then
        echo "Not allowed to create TODO list with name '$TARGET_FILE_NAME'"
        exit 1
    elif [ -f "$todoListFile" ]
    then
        echo "TODO list '$targetListName' already exist"
        exit 1
    fi

    echo "$targetListName" > "$targetFile"

    if [ ! -e "$todoListFile" ]
    then
        touch "$todoListFile"
    fi
}

function todo-target-delete() {
    local targetListName
    targetListName=$1

    local folder
    folder=$(findToDoListFolder)

    local targetFile
    targetFile="$folder/$TARGET_FILE_NAME"

    local todoListFile
    todoListFile="$folder/$targetListName"

    local target
    target=$(<"$targetFile")

    if [ "$targetListName" == "$TARGET_FILE_NAME" ] || [ "$targetListName" == "$TODO_FILE_NAME" ]
    then
        echo "Not allowed to delete '$targetListName'"
        exit 1
    fi

    if [ -f "$todoListFile" ]
    then
        rm "$todoListFile"
    fi

    if [ "$targetListName" == "$target" ]
    then
        echo "" > "$targetFile"
    fi
}

function functionNameExist() {
    local functionName
    functionName=$1

    local typeOfFunction
    typeOfFunction=`type -t "$functionName"`

    if [ "$typeOfFunction" = "function" ]; then
        echo true
    else
        echo false
    fi
}

function todo-target() {
    local targetCommand
    targetCommand="todo-target-$1"

    local targetCommandParams
    targetCommandParams="${@:2}"

    targetFunctionExist=$(functionNameExist "$command")
    if [ "$targetFunctionExist" = true ]; then
        "$targetCommand" $targetCommandParams
    else
        echo 'Unknown command'
        echo ''
        todo-help
        exit 1
    fi
}

functionExist=$(functionNameExist "$command")
if [ "$functionExist" = true ]; then
    "$command" $commandParams
else
    echo 'Unknown command'
    echo ''
    todo-help
    exit 1
fi
