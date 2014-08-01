docker run -i -t -p 9990:9990 -p 8080:8080 -p 9999:9999 -p 8787:8787 --link smtp:mail --name "dtgov_standalone" jboss_fsw/dtgov-standalone
