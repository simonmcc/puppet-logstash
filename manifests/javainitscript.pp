# templated java daemon script
define logstash::javainitscript (
  $serviceuser,
  $servicehome,
  $servicelogfile,
  $servicejar,
  $serviceargs,
  $servicename = $title,
  $servicegroup = $serviceuser,
  $serviceuserhome = $servicehome,
  $java_home = '/usr/lib/jvm/jre-1.6.0-openjdk.x86_64'
) {

  file { "/etc/init.d/${servicename}":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('logstash/javainitscript.erb')
  }
}
