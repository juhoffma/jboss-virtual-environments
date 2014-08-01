docker run -d -p 19990:9990 -p 18080:8080 -p 19999:9999 -h rtgov1 --name "rtgov_standalone1" jmorales_fsw/rtgov-standalone-ha:6.0
docker run -d -p 29990:9990 -p 28080:8080 -p 29999:9999 -h rtgov2 --link rtgov_standalone1:rtgov1 --name "rtgov_standalone2" jmorales_fsw/rtgov-standalone-ha:6.0
