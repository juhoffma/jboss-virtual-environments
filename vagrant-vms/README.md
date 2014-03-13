Vagrant-vms
====================================

This is a list of [vagrant] VMs ready for working with [JBoss] products:

* [FSW All in one](fsw-all-in-one): This is an installation of a [FSW] in one EAP (SwithYard, dtGov, rtGov, quickstarts)
* [FSW One vm separate EAPs](jboss-fsw-one-vm-separate-eaps): This is an installation of a [FSW] in one VM with 3 EAP (SwithYard, dtGov, rtGov, quickstarts)
* [FSW Separate VMs separate EAPs](jboss-fsw-separate-vm-separate-eaps): This is an installation of a [FSW] in different VMs (SwithYard, dtGov, rtGov, quickstarts)

To start a vm (run the following command inside a vm folder):

```sh
vagrant up
```

[vagrant]:http://www.vagrantup.com
[packer]:http://packer.io
[JBoss]:http://www.jboss.org/products
[FSW]:http://www.jboss.org/products/fsw.html
