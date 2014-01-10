# Install development packages
yum -y install java-1.7.0-openjdk-devel

echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0" > /etc/profile.d/java.sh
echo "export PATH=\"$PATH:$JAVA_HOME/bin\"" >> /etc/profile.d/java.sh
