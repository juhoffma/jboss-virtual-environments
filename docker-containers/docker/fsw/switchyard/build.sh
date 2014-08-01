#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jmorales_fsw/installers:6.0
docker run -t -i --name "sy_install" --volumes-from fsw_installers jmorales_fsw/base:6.0 /software/install-sy.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
# docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jmorales_fsw/base:6.0 /software/install-sy.sh
#
#
docker commit -m "SY installed" sy_install jmorales_fsw/sy:6.0
docker rm -f sy_install
docker rm -f sy_installers

# Build the appropiate images
echo "Creating the SwitchYard standalone image"
docker build --rm -t jmorales_fsw/sy-standalone:6.0 ./standalone/
echo "Creating the SwitchYard standalone-ha image"
docker build --rm -t jmorales_fsw/sy-standalone-ha:6.0 ./standalone-ha/
echo "Creating the SwitchYard standalone-full-ha image"
docker build --rm -t jmorales_fsw/sy-standalone-full-ha:6.0 ./standalone-full-ha/
