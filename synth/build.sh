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