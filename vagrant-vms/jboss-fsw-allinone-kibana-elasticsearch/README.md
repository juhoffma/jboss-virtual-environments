jboss-fsw-allinone-kibana-elasticsearch
====================================
This VM will install FSW 6.0 in /opt/fsw with user 
```
jboss:jboss 
```

JBoss admin user is
```
 admin/admin123!
```

It install elasticsearch (as a service): 

```
service elasticsearch start|stop
```

It installs Oracle JDK in /opt/java

To start a vm (run the following command inside a vm folder):

```sh
vagrant up
```

First time boot will do creation and provisioning, next time will start everything already installed.

Ports 8080, 9999 and 9990 are forwarded to host, so it can collide if you have something running on your host. If this is the case, just comment port forwarding, as machine is accesible at 10.15.2.10

NOTE:
Copy required binaries to manifest/files folder.

Required binaries can be:
FSW 6.0.0: jboss-fsw-installer-6.0.0.GA-redhat-4.jar
Oracle JDK 7u55: jdk-7u55-linux-x64.tar.gz

[vagrant]:http://www.vagrantup.com
[JBoss]:http://www.jboss.org/products
[FSW]:http://www.jboss.org/products/fsw.html
