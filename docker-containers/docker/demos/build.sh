for i in `ls -d */`
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
