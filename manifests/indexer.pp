# = Class: logstash::indexer
#
# Description of logstash::indexer
#
# == Parameters:
#
# none - all config is pulled from the logstash::config class
#
# == Actions:
#
# Installs the logstash jar & init script in the desired location
#
# == Requires:
#
# logstash::config
#
# == Todo:
#
# * Update documentation
#
class logstash::indexer (
) {

  # make sure the logstash::config class is declared before logstash::indexer
  Class['logstash::config'] -> Class['logstash::indexer']
  Class['logstash::package'] -> Class['logstash::indexer']

  User  <| tag == 'logstash' |>
  Group <| tag == 'logstash' |>

  $jarname = $logstash::config::logstash_jar
  $verbose = $logstash::config::logstash_verbose

  # create the config file based on the transport we are using
  # (this could also be extended to use different configs)
  case  $logstash::config::logstash_transport {
    /^redis$/: { $indexer_conf_content = template('logstash/indexer-input-redis.conf.erb',
                                                  'logstash/indexer-filter.conf.erb',
                                                  'logstash/indexer-output.conf.erb') }
    /^amqp$/:  { $indexer_conf_content = template('logstash/indexer-input-amqp.conf.erb',
                                                  'logstash/indexer-filter.conf.erb',
                                                  'logstash/indexer-output.conf.erb') }
    default:   { $indexer_conf_content = template('logstash/indexer-input-amqp.conf.erb',
                                                  'logstash/indexer-filter.conf.erb',
                                                  'logstash/indexer-output.conf.erb') }
  }

  file { "${logstash::config::logstash_etc}/indexer.conf":
    ensure  => 'file',
    group   => '0',
    mode    => '0644',
    owner   => '0',
    content => $indexer_conf_content,
    notify  => Service['logstash-indexer'],
  }

  # startup script
  logstash::javainitscript { 'logstash-indexer':
    serviceuser    => $logstash::config::user,
    servicegroup   => $logstash::config::group,
    servicehome    => $logstash::config::logstash_home,
    servicelogfile => "${logstash::config::logstash_log}/indexer.log",
    servicejar     => $logstash::package::jar,
    serviceargs    => " agent -f ${logstash::config::logstash_etc}/indexer.conf -l ${logstash::config::logstash_log}/indexer.log",
    java_home      => $logstash::config::java_home,
  }

  service { 'logstash-indexer':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => [ Logstash::Javainitscript['logstash-indexer'], Class['logstash::package'] ],
  }

  # if we're running with elasticsearch embedded, make sure the data dir exists
  if $logstash::config::elasticsearch_provider == 'embedded' {
    file { "${logstash::config::logstash_home}/data/elasticsearch":
      ensure => directory,
      owner  => $logstash::config::logstash_user,
      group  => $logstash::config::logstash_group,
      before => Service['logstash-indexer'],
      require => File["${logstash::config::logstash_home}/data"],
    }

    file { "${logstash::config::logstash_home}/data":
      ensure => directory,
      owner  => $logstash::config::logstash_user,
      group  => $logstash::config::logstash_group,
    }
  }
}

