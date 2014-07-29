#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jmorales_fsw/installers:6.0
docker run -t -i --name "fsw_install" --volumes-from fsw_installers jmorales_fsw/base:6.0 /software/install-fsw.sh
docker commit -m "FSW installed" fsw_install jmorales_fsw/fsw:6.0
docker rm -f fsw_install
docker rm -f fsw_installers

# Build the appropiate images
echo "Creating the standalone image"
docker build --rm -t jmorales_fsw/fsw-standalone:6.0 ./standalone/
echo "Creating the standalone-ha image"
docker build --rm -t jmorales_fsw/fsw-standalone-ha:6.0 ./standalone-ha/
echo "Creating the standalone-full-ha image"
docker build --rm -t jmorales_fsw/fsw-standalone-full-ha:6.0 ./standalone-full-ha/
