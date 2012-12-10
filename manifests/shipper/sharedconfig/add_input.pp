define logstash::shipper::sharedconfig::add_input($template='') {
  logstash::shipper::sharedconfig::add_config { $name:
    template => $template,
    order    => 100
  }
}
