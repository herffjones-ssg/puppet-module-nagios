# == Class: nagios::master
#
# Generate Nagios config and write it to enterprise.
#
class nagios::master {
  include ssh

  file { "/etc/nagios":
    ensure => "directory",
    mode   => '0755',
    purge  => true,
  }

  file { "/etc/nagios/hosts/":
    ensure => "directory",
    mode   => '0755',
    purge  => true,
  }

  file { "/etc/nagios/services/":
    ensure => "directory",
    mode   => '0755',
    purge  => true,
  }

  file { "/etc/nagios/websites/":
    ensure => "directory",
    mode   => '0755',
    purge  => true,
  }

  exec { "nagios_sync":
    refreshonly => true,
    command     => "rsync -rv --del --exclude='*.svn' /etc/nagios/ serversetup@enterprise.herffjones.hj-int:/etc/nagios/puppetmanaged/ && ssh serversetup@enterprise.herffjones.hj-int 'find /etc/nagios/puppetmanaged/ -not -wholename \"*.svn*\" -exec chmod 755 {} \;'",
    path        => ["/usr/bin", "/usr/local/bin"],
    notify      => Exec['nagios_restart'],
  }

  exec { "nagios_restart":
    refreshonly => true,
    command     => "ssh serversetup@enterprise.herffjones.hj-int 'sudo /etc/init.d/nagios restart'",
    path        => ["/usr/bin", "/usr/local/bin"],
  }

  Sshkey <<||>> {
    notify => Exec['merge_enterprise_hosts'],
  }

  Nagios_host <<||>> {
    notify  => Exec['nagios_sync'],
    require => [ File['/etc/nagios'], File['/etc/nagios/hosts/'], File['/etc/nagios/services/'], File['/etc/nagios/websites/'] ],
  }
  Nagios_service <<||>> {
    notify => Exec['nagios_sync'],
    require => [ File['/etc/nagios'], File['/etc/nagios/hosts/'], File['/etc/nagios/services/'], File['/etc/nagios/websites/'] ],
  }

}
