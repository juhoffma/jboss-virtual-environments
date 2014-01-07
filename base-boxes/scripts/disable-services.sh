#!/bin/bash
#######################################################
# Turn off un-needed services
#######################################################
chkconfig sendmail off
chkconfig vbox-add-x11 off
chkconfig smartd off
chkconfig ntpd off
chkconfig cupsd off

