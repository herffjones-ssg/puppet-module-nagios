class nagios::target (
  $notification_period = "24x7",
  $contact_groups = "devnull",
  $notification_interval = "60",
  $max_check_attempts = "50",
  $parents = "insw1",
  $notification_options = "d,r,f",
){

    # Setup the SSH Key for Nagios for the sshuser account
    ssh_authorized_key { "nagios_ssh_key":
      ensure => present,
      user   => "sshuser",
      type   => "dsa",
      key    => "AAAAB3NzaC1kc3MAAACBAKud2fsR8J3pGZunj+/UpBb8T4fQuPfAbSwZIgGJYvsmPZz6qsyoXTT3BnE+TK7jSy32H5glUYz3edFexAIiLC/5VVtRJ23+fsNdZs5NuxeAY67YdmdSumpjGi/IzqUKmj5GBo9jCHppHa/w4dorRw8CFAudSKLayNs0gi/0nn7fAAAAFQCcWMXGz6hKEN/Qgq7Z5wNYIkY0kwAAAIAmSf0g3Na4lc5XlsGifAPXXbWoCsHn1HbsP5TllBapyFAEy1ImIPKrfZJcmFOTopicxTH0Q76DYvVxhwbQV2asP++fJwkOKK5aAmhngOjE/FlanZBB3FxVx0bqieDkI5Vg1xfL4DxUpHSrWrJSGdtwoO2p4S+cfmtEyWhK2/s9QAAAAIEAhxSsxBMmTo25WnFGox7chg1VviOn6J0P3xjRwu4TySmfgyX1pQZydTsUPn3t3LwGm/l+60ezDBsiWd+jTGl4xbwtdeIAoVRNmOBm7rwU5YSAM5qbHDN7LppoJ36yYVW/AR+W9uFmbJBdOohWy5Zo5J0zf9vGXa3KPdlScSqUE0I=",
    }

   @@nagios_host { $fqdn:
      ensure                => present,
      host_name             => $hostname,
      alias                 => $hostname,
      address               => $fqdn,
      use                   => "generic-host",
      check_command         => "check-host-alive",
      max_check_attempts    => $max_check_attempts,
      parents               => $parents,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notification_interval => $notification_interval,
      notification_options  => $notification_options,
      target                => "/etc/nagios/hosts/${fqdn}.cfg",
   }

   @@nagios_service { "system_healthcheck_${hostname}":
      ensure              => present,
      use                 => "generic-service",
      service_description => "system_healthcheck",
      host_name           => $hostname,
      notification_period => $notification_period,
      check_command       => "system_healthcheck",
      contact_groups      => $contact_groups,
      target              => "/etc/nagios/services/${fqdn}.cfg",
   }

   # Create the mount checker on the target.
   file { "/usr/local/bin/mountchecker":
     ensure => file,
     owner  => 'root',
     group  => 'root',
     mode   => 0755,
     source => "puppet:///modules/nagios/mountchecker",
   }

   @@nagios_service { "mountchecker_${hostname}":
      ensure              => present,
      use                 => "generic-service",
      service_description => "mountchecker",
      host_name           => $hostname,
      notification_period => $notification_period,
      check_command       => "mountchecker",
      contact_groups      => $contact_groups,
      target              => "/etc/nagios/services/${fqdn}.cfg",
   }

}
