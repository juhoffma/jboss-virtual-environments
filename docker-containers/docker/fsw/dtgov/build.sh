#
# We delete intermediate containers to get minimal size
#
#docker run -d -v /software --name fsw_installers jmorales_fsw/installers:6.0
#docker run -t -i --name "dtgov_install" --volumes-from fsw_installers jmorales_fsw/base:6.0 /software/install-dtgov.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jmorales_fsw/base:6.0 /software/install-dtgov.sh
#
#
docker commit -m "DTGov installed" dtgov_install jmorales_fsw/dtgov:6.0.0
docker rm -f dtgov_install
# docker rm -f dtgov_installers

# Build the appropiate images
echo "Creating the DTGov standalone image"
docker build --rm -t jmorales_fsw/dtgov-standalone:6.0.0 ./standalone/
# echo "Creating the DTGov standalone-ha image"
# docker build --rm -t jmorales_fsw/dtgov-standalone-ha:6.0.0 ./standalone-ha/
# echo "Creating the DTGov standalone-full-ha image"
# docker build --rm -t jmorales_fsw/dtgov-standalone-full-ha:6.0.0 ./standalone-full-ha/
