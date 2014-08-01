#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jboss_fsw/installers
docker run -t -i --name "fsw_install" --volumes-from fsw_installers jboss/base /software/fsw/install-fsw.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
# docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jboss/base /software/install-fsw.sh
#
#
docker commit -m "FSW installed" fsw_install jboss_fsw/fsw
docker rm -f fsw_install
docker rm -f fsw_installers

# Build the appropiate images
echo "Creating the standalone image"
docker build --rm -t jboss_fsw/fsw-standalone ./standalone/
echo "Creating the standalone-ha image"
docker build --rm -t jboss_fsw/fsw-standalone-ha ./standalone-ha/
echo "Creating the standalone-full-ha image"
docker build --rm -t jboss_fsw/fsw-standalone-full-ha ./standalone-full-ha/
