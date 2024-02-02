#!/usr/bin/env bash

cd $(dirname $0)

Moveon(){
    if [ $? != 0 ]; then
        echo -en "\e[1;31m执行失败! \e[0m"
        while :
        do
            echo -en '是否继续[y/\e[4mn\e[0m]: '
            read inword
            if [ -z ${inword} ]; then
                inword='no'
            fi
            case $inword in
            n|N|no|NO|No)
                exit;;
            y|Y|yes|Yes|YES)
                break;;
            *)
                echo 'input error!';;
            esac
        done
    fi
}


git add .
Moveon
git commit -m "$(date)"
Moveon
git push
Moveon

echo '脚本执行完成...'
sleep 3