# Base install

# Make tty not required for sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

