#!/bin/bash

set -e

rtp=./vim-rtp

for dir in colors syntax;do
    [[ -e $rtp/$dir ]] || mkdir -p $rtp/$dir
done

declare -a vim_assets=(
    "syntax/coffee.vim"         "https://raw.githubusercontent.com/kchmck/vim-coffee-script/master/syntax/coffee.vim"
    "syntax/turtleson.vim"      "https://raw.githubusercontent.com/kba/turtleson.vim/master/syntax/turtleson.vim"
    "colors/jellybeans.vim"     "https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim"
    "syntax/seoul256.vim"       "https://raw.githubusercontent.com/junegunn/seoul256.vim/master/colors/seoul256.vim"
    "syntax/seoul256-light.vim" "https://raw.githubusercontent.com/junegunn/seoul256.vim/master/colors/seoul256-light.vim"
    "colors/monokai.vim"        "https://raw.githubusercontent.com/kba/vim-monokai/master/colors/monokai.vim"
)

i=0
while [[ $i -lt ${#vim_assets[@]} ]];do
    file="$rtp/${vim_assets[$i]}"
    url=${vim_assets[$(($i+1))]}
    if [[ ! -e $file ]];then
        echo wget "$url" -O - \> "$file" 
        wget "$url" -O - > "$file" 
    fi
    i=$(( $i + 2 ))
done
