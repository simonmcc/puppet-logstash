# = Class: logstash::redis
#
# Manage installation & configuration of a redis server (to be used by logstash)
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
# * Add support for other ways providing redis?
#
class logstash::redis (
) {

  # make sure the logstash::config class is declared before logstash::server
  Class['logstash::config'] -> Class['logstash::redis']

  if $logstash::config::redis_provider == 'package' {

    # build a package-version if we need to
    $redis_package = $logstash::config::redis_version ? {
      /\d+./    => $::operatingsystem ? {
        debian  => "${logstash::config::redis_package}=${logstash::config::redis_version}",
        default => "${logstash::config::redis_package}-${logstash::config::redis_version}" 
      },
      default => $logstash::config::redis_package,
    }

    package { $redis_package:
      ensure => present,
    }


    # operatingsystem specific file & service names
    case $operatingsystem {
      centos, redhat, OEL: { $redis_conf = '/etc/redis.conf'
                        $redis_service = 'redis' }
      ubuntu, debian: { $redis_conf = '/etc/redis/redis.conf'
                        $redis_service = 'redis-server' }
      default: { fail("Unsupportted operating system ($operatingsystem)") }
    }

    # our redis config file
    file { "$redis_conf":
      ensure  => present,
      content => template('logstash/redis.conf.erb'),
      require => Package[$redis_package],
    }

    # make sure the service is defined & running
    service { "$redis_service":
      ensure    => 'running',
      hasstatus => true,
      enable    => true,
      subscribe => File[$redis_conf],
      require   => File[$redis_conf],
    }
  }
}
