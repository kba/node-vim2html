#!/bin/bash

set -e

rtp=./vim-rtp

for dir in colors syntax;do
    [[ -e $rtp/$dir ]] || mkdir -p $rtp/$dir
done

declare -a vim_assets=(
    "colors/jellybeans.vim"     "https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim"
    "colors/seoul256.vim"       "https://raw.githubusercontent.com/junegunn/seoul256.vim/master/colors/seoul256.vim"
    "colors/seoul256-light.vim" "https://raw.githubusercontent.com/junegunn/seoul256.vim/master/colors/seoul256-light.vim"
    "colors/monokai.vim"        "https://raw.githubusercontent.com/kba/vim-monokai/master/colors/monokai.vim"
    "syntax/coffee.vim"         "https://raw.githubusercontent.com/kchmck/vim-coffee-script/master/syntax/coffee.vim"
    "syntax/turtleson.vim"      "https://raw.githubusercontent.com/kba/turtleson.vim/master/syntax/turtleson.vim"
    "syntax/n3.vim"             "https://raw.githubusercontent.com/neapel/vim-n3-syntax/master/syntax/n3.vim"
)

i=0
while [[ $i -lt ${#vim_assets[@]} ]];do
    file="$rtp/${vim_assets[$i]}"
    url=${vim_assets[$(($i+1))]}
    if [[ ! -e $file || -s $file ]];then
        echo wget "$url" -O - \> "$file" 
        wget "$url" -O - > "$file" 2>/dev/null
    fi
    i=$(( $i + 2 ))
done
