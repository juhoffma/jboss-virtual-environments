docker run -d -p 19990:9990 -p 18080:8080 -p 19999:9999 -h fsw1 --name "fsw_standalone1" jboss_fsw/fsw-standalone-ha
docker run -d -p 29990:9990 -p 28080:8080 -p 29999:9999 -h fsw2 --link fsw_standalone1:fsw1 --name "fsw_standalone2" jboss_fsw/fsw-standalone-ha
