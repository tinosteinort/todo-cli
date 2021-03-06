# TODO list - a CLI tool

A tool to manage multiple TODO lists via a CLI.

![Example Image](example.png)

The TODO lists are saved as plain text files, one file per TODO list.

## Build and installation
```
./build.sh && sudo ./install.sh
```
For the installation `sudo` is needed, because the bash autocompletion the 
 folder `/etc/bash_completion.d` must be writable.


## Managing TODO entries

* ### Init a new TODO folder
    ```
    todo init
    ```
    Within this directory, and all child directories, the `todo`
     command will work. With this command, also the default TODO
     list `todo` is created.

* ### Add a point to the current TODO list
    ```
    todo add "clean the house"
    todo add "buy all the things
    ```

* ### Show all tasks
    ```
    todo list
    ```
    This will show you a list with all tasks. Each task has a number.
     You need this number to check / uncheck a task.

* ### Check a task
    ```
    todo check 2
    ```
    Checks the task with the number `2`.
    
* ### Unheck a task
    ```
    todo uncheck 1
    ```
    Unchecks the task with the number `1`.
    
* ### Remove a task
    ```
    todo remove 2
    ```
    Remove the task with the given number from the current TODO list.


## Managing TODO lists (targets)

* ### Show available TODO lists
    ```
    todo target list
    ```

* ### Create a new TODO lists
    ```
    todo target create "home"
    todo target create "office"
    ```

* ### Select an other TODO list
    ```
    todo target select "home"
    ```

* ### Delete a TODO list
    ```
    todo target delete "office"
    ```
    When a target (TODO list) is deleted, all entries of this list are also lost.
