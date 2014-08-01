docker run -d -p 19990:9990 -p 18080:8080 -p 19999:9999 -h sy1 --name "sy_standalone1" jboss_fsw/sy-standalone-ha
docker run -d -p 29990:9990 -p 28080:8080 -p 29999:9999 -h sy2 --link sy_standalone1:sy1 --name "sy_standalone2" jboss_fsw/sy-standalone-ha
