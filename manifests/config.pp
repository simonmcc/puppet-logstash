# = Class: logstash::config
#
# This is the shared config class for the logstash module, override the sensible defaults as you see fit
#
# == Actions:
#
# Primarily a config class for logstash
#
# == Requires:
#
# Requirements. This could be packages that should be made available.
#
# == Sample Usage:
# redis_provider = package|external
#                  package  - we'll declare and ensure a redis package, using $redis_version
#                  external - assume redis is being installed outside of this module
# == Todo:
#
# * Update documentation
#
class logstash::config( $logstash_home = '/usr/local/logstash',
  $logstash_etc = '/etc/logstash',
  $logstash_log = '/var/log/logstash',
  $logstash_transport = 'amqp',
  $logstash_jar_provider = 'package',
  $logstash_version = '1.1.5',
  $logstash_verbose = 'no',
  $logstash_user  = 'logstash',
  $logstash_group = 'logstash',
  $elasticsearch_provider = 'external',
  $elasticsearch_host = '127.0.0.1',
  $redis_provider = 'external',
  $redis_package = 'redis',
  $redis_version = '2.4.15',
  $redis_host = '127.0.0.1',
  $redis_port = '6379',
  $redis_key = 'logstash',
  $java_provider = 'package',
  $java_package = 'java-1.6.0-openjdk',
  $java_home = '/usr/lib/jvm/jre-1.6.0-openjdk.x86_64'
) {

  # just trying to make the fq variable a little less rediculous
  $user = $logstash_user
  $group = $logstash_group

  # create parent directory and all folders beneath it.
  file { $logstash_home:
    ensure   => 'directory',
  }

  file { "${logstash_home}/bin/":
    ensure  => 'directory',
    require => File[$logstash_home],
  }
  file { "${logstash_home}/lib/":
    ensure  => 'directory',
    require => File[$logstash_home],
  }

  file { "$logstash_etc":
    ensure  => 'directory',
  }

  file { "$logstash_log":
    ensure   => 'directory',
    recurse  => true,
  }

  # make sure we have a logstash jar (& dependencies, if we want)
  class { 'logstash::package':
    logstash_home     => $logstash_home,
    logstash_provider => $logstash_jar_provider,
    java_provider     => $java_provider,
    java_package      => $java_package,
  }

  # create the service user & group if required
  class { 'logstash::user':
    logstash_homeroot => $logstash::config::logstash_home
  }
}

