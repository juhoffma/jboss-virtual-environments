#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jmorales_fsw/installers:6.0
docker run -t -i --name "rtgov_install" --volumes-from fsw_installers jmorales_fsw/base:6.0 /software/install-rtgov.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
# docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jmorales_fsw/base:6.0 /software/install-rtgov.sh
#
#
docker commit -m "RTGov installed" rtgov_install jmorales_fsw/rtgov:6.0
docker rm -f rtgov_install
docker rm -f rtgov_installers

# Build the appropiate images
echo "Creating the RTGov standalone image"
docker build --rm -t jmorales_fsw/rtgov-standalone:6.0 ./standalone/
echo "Creating the RTGov standalone-ha image"
docker build --rm -t jmorales_fsw/rtgov-standalone-ha:6.0 ./standalone-ha/
echo "Creating the RTGov standalone-full-ha image"
docker build --rm -t jmorales_fsw/rtgov-standalone-full-ha:6.0 ./standalone-full-ha/
