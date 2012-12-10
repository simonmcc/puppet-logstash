define logstash::shipper::sharedconfig::add_filter($template='') {

  if (!defined(Package['grok'])) {
    package { 'grok':
      ensure => installed
    }
  }

  logstash::shipper::sharedconfig::add_config { $name:
    template => $template,
    order    => 200
  }
}
