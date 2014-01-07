# Add jboss user
/usr/sbin/groupadd jboss
/usr/sbin/useradd jboss -g jboss -G wheel
echo "jboss"|passwd --stdin jboss
echo "jboss        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/jboss
chmod 0440 /etc/sudoers.d/jboss
