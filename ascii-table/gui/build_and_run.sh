#!/bin/bash

bin="bin"
main="main.com"
path_to_main="${bin}/$main"
temp_run_file="run__temp.bat"
path_to_temp_file="${bin}/$temp_run_file"

if [ ! -d $bin ];
    then
        mkdir -p $bin;
    else
        rm $bin/*
fi

nasm src/main.asm -o $path_to_main


touch $path_to_temp_file
echo "@echo off"                    >> $path_to_temp_file
echo "cls"                          >> $path_to_temp_file
if [ "$1" = "debug" ];
    then
        td="TD.EXE"
        cp ../../deps/$td $bin
        echo "${td} $main"          >> $path_to_temp_file
    else
        echo $main                  >> $path_to_temp_file
fi

if [ -d $1 ]; then
    echo "echo."                        >> $path_to_temp_file
    echo "pause Press any key to exit"  >> $path_to_temp_file
fi
echo "exitemu"                      >> $path_to_temp_file

dosemu $path_to_temp_file
