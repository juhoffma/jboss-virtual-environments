group { "jboss":
        ensure => present
}

user { 'jboss':
   home => '/home/jboss',
   shell => '/bin/bash',
   groups => ['jboss'],
   ensure => 'present'
}

host { 'sy':
  ensure    => 'present',
  ip        => '10.11.1.10'
}

package { 'expect':
  ensure    => 'present'
}

file { "installer":
    path    => "/tmp/jboss-fsw-installer-6.0.0.GA-redhat-4.jar",
    ensure  => file,
    source  => "puppet:////vagrant/manifests/files/jboss-fsw-installer-6.0.0.GA-redhat-4.jar"
}

#file { "jbds-installer":
#    path    => "/tmp/jbdevstudio-installer.jar",
#    ensure  => file,
#    source  => "puppet:////vagrant/manifests/files/jbdevstudio-product-universal-7.1.0.GA-v20131208-0703-B592.jar"
#}
