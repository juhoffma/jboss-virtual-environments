#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jboss_fsw/installers
docker run -t -i --name "dtgov_install" --volumes-from fsw_installers jboss/base /software/dtgov/install-dtgov.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
# docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jboss/base /software/install-dtgov.sh
#
#
docker commit -m "DTGov installed" dtgov_install jboss_fsw/dtgov
docker rm -f dtgov_install
# docker rm -f dtgov_installers

# Build the appropiate images
echo "Creating the DTGov standalone image"
docker build --rm -t jboss_fsw/dtgov-standalone ./standalone/
echo "Creating the DTGov standalone-ha image"
docker build --rm -t jboss_fsw/dtgov-standalone-ha ./standalone-ha/
echo "Creating the DTGov standalone-full-ha image"
docker build --rm -t jboss_fsw/dtgov-standalone-full-ha ./standalone-full-ha/
