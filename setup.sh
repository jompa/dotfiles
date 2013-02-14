#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare -a symlinks=( ".zshrc" ".alias" ".vim" ".vimrc")

for var in ${symlinks[@]}
do
    if [ -f "$SCRIPT_DIR/$var" ]
        then
        echo "linking $SCRIPT_DIR/$var"
        ln -s $SCRIPT_DIR/$var $HOME/$var
        else
            echo "could not find $SCRIPT_DIR/$var"
            exit
    fi

    echo $HOME
    echo $DIR
done
