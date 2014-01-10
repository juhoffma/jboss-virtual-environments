base-boxes
============================
Here, we can create base-boxes ready with [packer] set up to work with [vagrant] and [JBoss] products.


##### Available boxes

* centos 6.5 x86_64

To create the box:
---sh
packer build centos-6_5-64.json
---

To add the box to vagrant repository of boxes:
---sh
vagrant box add centos-6.5-64-jboss centos-6.5-64-jboss.box
---

If the box is already added, and you want to update it, first remove it:
---sh
vagrant box remove centos-6.5-64-jboss
---


[vagrant]:http://www.vagrantup.com
[packer]:http://packer.io
[JBoss]:http://www.jboss.org/products
