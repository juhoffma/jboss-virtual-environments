#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jboss/installers
docker run -t -i --name "rtgov_install" --volumes-from fsw_installers jboss/base /software/rtgov/install-rtgov.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
# docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jboss/base /software/install-rtgov.sh
#
#
docker commit -m "RTGov installed" rtgov_install jboss_fsw/rtgov
docker rm -f rtgov_install
docker rm -f rtgov_installers

# Build the appropiate images
echo "Creating the RTGov standalone image"
docker build --rm -t jboss_fsw/rtgov-standalone ./standalone/
echo "Creating the RTGov standalone-ha image"
docker build --rm -t jboss_fsw/rtgov-standalone-ha ./standalone-ha/
echo "Creating the RTGov standalone-full-ha image"
docker build --rm -t jboss_fsw/rtgov-standalone-full-ha ./standalone-full-ha/
