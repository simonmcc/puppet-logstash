input {
  log4j {
    # ship logs to the 'rawlogs' fanout queue.
    type => "all"
    port => <%= log4j_port %>
  }
}
