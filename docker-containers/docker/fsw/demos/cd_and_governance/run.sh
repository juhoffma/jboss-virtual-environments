# Start mail server
docker run -d --name "govdemo_mail" jmorales/smtp

# Start some switchyard servers per environment
docker run -d -p 19990:9990 -p 8090:8080 -h dev   -v /home/jboss/dev   --name "govdemo_sy_dev"   governance_demo/sy:1.0.0
docker run -d -p 19991:9990 -p 8091:8080 -h qa    -v /home/jboss/qa    --name "govdemo_sy_qa"    governance_demo/sy:1.0.0
docker run -d -p 19992:9990 -p 8092:8080 -h stage -v /home/jboss/stage --name "govdemo_sy_stage" governance_demo/sy:1.0.0

# Start dtgov server
docker run -d -p 19993:9990 -p 8190:8080 -h dtgov --volumes-from="govdemo_sy_dev" --volumes-from="govdemo_sy_qa" --volumes-from="govdemo_sy_stage" --link govdemo_mail:mail --link govdemo_sy_dev:dev --link govdemo_sy_qa:qa --link govdemo_sy_stage:stage --name "govdemo_dtgov" governance_demo/dtgov:1.0.0
