ls -l software > files_list.txt
docker build --rm -t "jboss_fsw/installers:latest"  .
docker tag jboss_fsw/installers:latest jboss_fsw/installers:6.0.0
