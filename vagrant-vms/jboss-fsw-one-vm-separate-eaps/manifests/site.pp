file { "installer":
    path    => "/tmp/jboss-fsw-installer-6.0.0.GA-redhat-4.jar",
    ensure  => file,
    source  => "puppet:////vagrant/manifests/files/jboss-fsw-installer-6.0.0.GA-redhat-4.jar"
}



group { "jboss":
        ensure => present
}->

user { 'jboss':
   home => '/home/jboss',
   shell => '/bin/bash',
   groups => ['jboss'],
   ensure => 'present'
}->

host { 'sy':
  ensure    => 'present',
  ip        => '10.11.2.11'
}->

host { 'rtgov':
  ensure    => 'present',
  ip        => '10.11.2.12'
}->

host { 'dtgov':
  ensure    => 'present',
  ip        => '10.11.2.13'
}->

package { 'expect':
  ensure    => 'present'
}->

file { '/tmp/fixhwaddr.sh':
   ensure => present,
   owner => 'root',
   group => 'root',
   mode => '0755',
   source => 'puppet:////vagrant/manifests/files/fixhwaddr.sh',
}->

exec { 'fix_eth1':
   command => '/tmp/fixhwaddr.sh eth1',
   require => File['/tmp/fixhwaddr.sh'] 
}->

exec { 'fix_eth2':
   command => '/tmp/fixhwaddr.sh eth2', 
   require => File['/tmp/fixhwaddr.sh'] 
}->

exec { 'fix_eth3':
   command => '/tmp/fixhwaddr.sh eth3',
   require => File['/tmp/fixhwaddr.sh'] 
}->

exec { 'restart_network':
   command => '/sbin/service network restart'
}
