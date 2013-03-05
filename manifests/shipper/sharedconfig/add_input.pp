define logstash::shipper::sharedconfig::add_input (
  $template = '',
  $plugin   = $name,
  $config   = {},
) {
  logstash::shipper::sharedconfig::add_config { $name:
    template => $template,
    order    => 100
  }
}
