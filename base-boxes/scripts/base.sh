# Base install
yum install -y sudo xorg-x11-xauth  libXtst

# Make tty not required for sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Customize the message of the day
echo 'Welcome to your virtual machine for playing with JBoss products.' > /etc/motd
