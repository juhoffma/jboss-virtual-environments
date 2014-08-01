#
# We delete intermediate containers to get minimal size
#
docker run -d -v /software --name fsw_installers jboss_fsw/installers
docker run -t -i --name "sy_install" --volumes-from fsw_installers jboss/base /software/sy/install-sy.sh
#
# If you dont have the volume with the software, but have it locally, can build with (replace two lines above):
# docker run -t -i --name "dtgov_install" -v /home/jmorales/repositories/jorgemoralespou/jboss-virtual-environments.git/docker-containers/docker/fsw/installers/software:/software jboss_fsw/base:${FSW_VERSION} /software/install-sy.sh
#
#
docker commit -m "SY installed" sy_install jboss_fsw/sy
docker rm -f sy_install
docker rm -f sy_installers

# Build the appropiate images
echo "Creating the SwitchYard standalone image"
docker build --rm -t jboss_fsw/sy-standalone ./standalone/

echo "Creating the SwitchYard standalone-ha image"
docker build --rm -t jboss_fsw/sy-standalone-ha:latest ./standalone-ha/

echo "Creating the SwitchYard standalone-full-ha image"
docker build --rm -t jboss_fsw/sy-standalone-full-ha:latest ./standalone-full-ha/
