# Class: logstash::user
#
# logstash_homeroot must be passed.
class logstash::user (
  $logstash_homeroot = undef
) {

  # make sure the logstash::config class is declared before logstash::user
  Class['logstash::config'] -> Class['logstash::user']

  User {
    ensure     => present,
    managehome => true,
    shell      => '/bin/false',
    system     => true
  }

  Group {
    ensure  => present,
    require => User[$logstash::config::user]
  }

  @user { $logstash::config::user:
    comment => 'logstash system account',
    tag     => 'logstash',
    uid     => $logstash::config::uid,
    home    => "${logstash_homeroot}/logstash";
  }

  @group { $logstash::config::group:
    gid => $logstash::config::gid,
    tag => 'logstash';
  }
}
