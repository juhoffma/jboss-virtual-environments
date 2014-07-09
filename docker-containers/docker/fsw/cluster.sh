docker run -d -p 19990:9990 -p 18080:8080 -h fsw1 --name "fsw_standalone1" jmorales_fsw/standalone-ha:6.0
docker run -d -p 29990:9990 -p 28080:8080 -h fsw2 --link fsw_standalone1:fsw1 --name "fsw_standalone2" jmorales_fsw/standalone-ha:6.0
