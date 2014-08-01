docker run -d -p 19990:9990 -p 18080:8080 -p 19999:9999 -h dtgov1 --name "dtgov_standalone1" jmorales_fsw/dtgov-standalone-ha:6.0
docker run -d -p 29990:9990 -p 28080:8080 -p 29999:9999 -h dtgov2 --link dtgov_standalone1:dtgov1 --name "dtgov_standalone2" jmorales_fsw/dtgov-standalone-ha:6.0
