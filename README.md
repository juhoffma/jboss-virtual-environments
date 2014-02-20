jboss-virtual-environments
==========================

[vagrant] machines for working with JBoss products

We have:
  - base-boxes: to create base systems to then add products. These base boxes are created with [packer].
  - vagrant-vms: Virtual machines with different setups and products installed to demonstrate some functionality

Installation
--------------

```sh
git clone [git-repo-url] jboss-virtual-environments
cd jboss-virtual-environments
```

##### Instructions in following README.md files

* [base boxes](base-boxes/README.md): These repositories let you create base boxes used for vagrant vms.
* [Vagrant VMs](vagrant-vms/README.md): These are prebuilt vagrant VMs to demo some [JBoss] MDW functionalities.


[packer]:http://packer.io/
[vagrant]:http://www.vagrantup.com
[JBoss]:http://www.jboss.org/products
