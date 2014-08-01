pushd ./installers
 ./build.sh
popd
for i in `ls -d */ | grep -v installers`
do
   pushd ${i}
   if [ -f build.sh ]
   then
      ./build.sh
   else
      echo "====== NO BUILD IN $(pwd) ============"
   fi
   popd
done
