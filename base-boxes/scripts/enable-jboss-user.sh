# Add jboss user
/usr/sbin/groupadd jboss
/usr/sbin/useradd jboss -g jboss -G wheel
echo "jboss"|passwd --stdin jboss
echo "jboss        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/jboss
chmod 0440 /etc/sudoers.d/jboss

# Installing vagrant keys, for passwordless ssh
mkdir -pm 700 /home/jboss/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/jboss/.ssh/authorized_keys
chmod 0600 /home/jboss/.ssh/authorized_keys
chown -R jboss /home/jboss/.ssh
