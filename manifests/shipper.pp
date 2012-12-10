# = Class: logstash::shipper
#
# Description of logstash::shipper
#
# == Parameters:
#
# $param::   description of parameter. default value if any.
#
# == Actions:
#
# Describe what this class does. What gets configured and how.
#
# == Requires:
#
# Requirements. This could be packages that should be made available.
#
# == Sample Usage:
#
# == Todo:
#
# * Update documentation
#
class logstash::shipper (
  $logstash_server ='localhost',
  $verbose = 'no',
  $jarname ='logstash-1.1.0-monolithic.jar',
  $config_strategy = 'logstash::shipper::defaultconfig',
  $config_params = {
    logfiles  => '"/var/log/messages", "/var/log/syslog", "/var/log/*.log"'
  }
) {

  # make sure the logstash::config & logstash::package classes are declared before logstash::shipper
  Class['logstash::config'] -> Class['logstash::shipper']
  Class['logstash::package'] -> Class['logstash::shipper']

  # Open the strategy for config file generating 

  class { $config_strategy:
    logstash_server => $logstash_server,
    configfile      => '/etc/logstash/shipper.conf',
    params          => $config_params
  }

  User  <| tag == 'logstash' |>
  Group <| tag == 'logstash' |>

  # startup script
  logstash::javainitscript { 'logstash-shipper':
    serviceuser    => 'root',
    servicegroup   => 'root',
    servicehome    => $logstash::config::logstash_home,
    servicelogfile => "$logstash::config::logstash_log/shipper.log",
    servicejar     => $logstash::package::jar,
    serviceargs    => " agent -f /etc/logstash/shipper.conf -l $logstash::config::logstash_log/shipper.log",
    java_home      => $logstash::config::java_home,
  }

  service { 'logstash-shipper':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => Logstash::Javainitscript['logstash-shipper'],
  }

}

