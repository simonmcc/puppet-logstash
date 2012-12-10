define logstash::shipper::sharedconfig::add_output($template='') {
  logstash::shipper::sharedconfig::add_config { $name:
    template => $template,
    order    => 300
  }
}

