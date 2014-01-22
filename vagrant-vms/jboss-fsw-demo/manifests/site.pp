
host { 'sy1':
  ensure    => 'present',
  ip        => '10.10.3.11'
}

host { 'sy2':
  ensure    => 'present',
  ip        => '10.10.3.12'
}

host { 'rtgov1':
  ensure    => 'present',
  ip        => '10.10.3.21'
}

host { 'rtgov2':
  ensure    => 'present',
  ip        => '10.10.3.22'
}

host { 'dtgov1':
  ensure    => 'present',
  ip        => '10.10.3.31'
}

host { 'dtgov2':
  ensure    => 'present',
  ip        => '10.10.3.32'
}

host { 'sramp1':
  ensure    => 'present',
  ip        => '10.10.3.41'
}

host { 'sramp2':
  ensure    => 'present',
  ip        => '10.10.3.42'
}

host { 'db1':
  ensure    => 'present',
  ip        => '10.10.3.51'
}


