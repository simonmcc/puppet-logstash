# = Class: logstash::shipper::defaultconfig
#
# Startegy class which generates a Logstash shipper configuration depending on the
# configured transport.
#
# == Parameters:
#
# $logstash_server:: Address of the logstash server (indexer)
# $configfile::      Absolute path to the logstash shipper configuration file
# $params::          Parameter hash which is passed to this strategy class. This class supports the key "logfiles".
#
# == Actions:
#
# Generates a shipper configuration, depending on transport defined in logstash::config.
#
# == Requires:
#
# == Sample Usage:
#
# == Todo:
#
class logstash::shipper::defaultconfig (
  $logstash_server,
  $configfile,
  $params={
    logfiles => '"/var/log/messages", "/var/log/syslog", "/var/log/*.log"'
  }
) {

  Class['logstash::config'] -> Class['logstash::shipper']

  case  $logstash::config::logstash_transport {
    /^redis$/: { $shipper_conf_content = template('logstash/shipper-input.conf.erb',
                                                  'logstash/shipper-filter.conf.erb',
                                                  'logstash/shipper-output-redis.conf.erb') }
    /^amqp$/:  { $shipper_conf_content = template('logstash/shipper-input.conf.erb',
                                                  'logstash/shipper-filter.conf.erb',
                                                  'logstash/shipper-output-amqp.conf.erb') }
    default:   { $shipper_conf_content = undef }
  }

   file { $configfile:
    ensure  => 'file',
    group   => '0',
    mode    => '0644',
    owner   => '0',
    content => $shipper_conf_content,
    notify  => Service['logstash-shipper']
  }
}
