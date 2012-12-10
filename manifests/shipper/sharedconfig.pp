# = Class: logstash::shipper::sharedconfig
#
# Strategy class which generates a Logstash shipper configuration. Other Puppet modules
# can add their filter, input or output configurations to the shipper configuration.
#
# == Parameters:
#
# $logstash_server:: The address of the logstash server.
# $configfile::      The absolute path to the logstash shipper configuration.
# $params::          Parameter hash passed to this strategy class (not needed by this strategy yet).
#
# == Actions:
#
# Generates the Logstash shipper configuration using the Puppet-Concat module.
# The benefit of a shared configuration is, that other modules are able to 
# add Logstash configuration units. Three defines are provided to add filter, input or output configurations:
#
# * logstash::shipper::sharedconfig::add_filter
# * logstash::shipper::sharedconfig::add_input
# * logstash::shipper::sharedconfig::add_output
#
# Disadvantage: other modules using such a define are coupled to this logstash module.
# 
# == Requires:
#
# puppet-concat (see https://github.com/ripienaar/puppet-concat)
#
# == Sample Usage:
#
# == Todo:
#
class logstash::shipper::sharedconfig (
  $logstash_server,
  $configfile,
  $params = {}
) {

  Class['logstash::config'] -> Class['logstash::shipper::sharedconfig']

  concat { $configfile:
    owner  => '0',
    group  => '0',
    mode   => '0644',
    order  => 'numeric',
    notify => Service['logstash-shipper']
  }

  case  $logstash::config::logstash_transport {
    /^redis$/: {
      $output_conf = template('logstash/sharedconfig/shipper-output-redis.conf.erb')
    }
    /^amqp$/:  {
      $output_conf = template('logstash/sharedconfig/shipper-output-amqp.conf.erb') 
    }
    default: {
      $output_conf = '' 
    }
  }

  concat::fragment {
    'input':
      target  => $configfile,
      content => "input {\n",
      order   => 0;
    'filter':
      target  => $configfile,
      content => "}\n\nfilter {\n",
      order   => 101;
    'output':
      target  => $configfile,
      content => "}\n\noutput {\n${output_conf}\n",
      order   => 201;
    'close':
      target  => $configfile,
      content => "\n}",
      order   => 999
  }

}
