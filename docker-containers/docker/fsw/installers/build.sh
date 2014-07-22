ls -l software > files_list.txt
docker build --rm -t "jmorales_fsw/installers:6.0"  .
