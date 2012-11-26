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
  $jarname = "logstash-$logstash::config::logstash_version-monolithic.jar",
  # TODO This needs refactoring :)
  $logfiles = '"/var/log/messages", "/var/log/syslog", "/var/log/*.log"'
) {

  # make sure the logstash::config & logstash::package classes are declared before logstash::shipper
  Class['logstash::config'] -> Class['logstash::shipper']
  Class['logstash::package'] -> Class['logstash::shipper']

  # create the config file based on the transport we are using (this could also be extended to use different configs)
  case  $logstash::config::logstash_transport {
    /^redis$/: { $shipper_conf_content = template('logstash/shipper-input.conf.erb',
                                                  'logstash/shipper-filter.conf.erb',
                                                  'logstash/shipper-output-redis.conf.erb') }
    /^amqp$/:  { $shipper_conf_content = template('logstash/shipper-input.conf.erb',
                                                  'logstash/shipper-filter.conf.erb',
                                                  'logstash/shipper-output-amqp.conf.erb') }
    default:   { $shipper_conf_content = undef }
  }


  file {'/etc/logstash/shipper.conf':
    ensure  => 'file',
    group   => '0',
    mode    => '0644',
    owner   => '0',
    content => $shipper_conf_content
  }

  # make sure the logstash::config class is declared before logstash::indexer
  Class['logstash::config'] -> Class['logstash::shipper']

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

