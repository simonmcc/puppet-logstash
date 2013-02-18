# templated java daemon script
define logstash::javainitscript (
  $servicename      = $title,
  $serviceuser,
  $servicegroup     = $serviceuser,
  $servicehome,
  $serviceuserhome  = $servicehome,
  $servicelogfile,
  $servicejar,
  $serviceargs,
  $java_home        = '/usr/lib/jvm/jre-1.6.0-openjdk.x86_64'
) {

  file { "/etc/init.d/${servicename}":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('logstash/javainitscript.erb')
  }
}
