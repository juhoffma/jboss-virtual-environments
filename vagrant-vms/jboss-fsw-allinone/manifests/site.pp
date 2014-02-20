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
