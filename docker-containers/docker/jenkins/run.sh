#
#
#
echo "You can add a volume /jenkins to store all configuration"
echo ""
echo "Container name: jenkins"
echo "Listening on port: 8091"
docker run -d -p 8091:8080 --name "jenkins" jmorales/jenkins
