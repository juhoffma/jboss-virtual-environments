pushd base
./build.sh
popd

pushd services
./build.sh
popd

pushd continuous
./build.sh
popd

pushd jboss
./build.sh
popd

pushd demos
./build.sh
popd

