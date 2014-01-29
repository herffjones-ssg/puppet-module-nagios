# == Class: nagios
#
# Full description of class nagios here.
#
class nagios (
  $master = False
) {

  # If we want to write config, use nagios::master
  if $master == "true" {
    include nagios::master
  }

  # If we just want to export, use nagios::target
  include nagios::target

  exec { "merge_enterprise_hosts":
    refreshonly => true,
    command     => "scp /etc/ssh/ssh_known_hosts serversetup@enterprise.herffjones.hj-int:/etc/nagios/puppetmanaged/known_hosts.puppet && ssh serversetup@enterprise.herffjones.hj-int 'sudo /usr/local/bin/do_merge_known_hosts /etc/nagios/puppetmanaged/known_hosts.puppet'",
    path        => ["/usr/bin", "/usr/local/bin"],
  }

}
