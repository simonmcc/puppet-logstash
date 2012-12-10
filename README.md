#puppet-logstash#

* Simple puppet logstash module, tries to take care of making sure redis &
elasticsearch are available.
* Supports grabbing logstash jar directly (jar's are packages right?  we just don't support them natively yet :-))
* aimed at logstash-1.1 or newer, with simple redis setup
* templated init scripts for all java daemons (based on work by Josh Davis/Christian d'Heureuse)

##Usage##

Declare a config class that is used by the working classes:

```puppet
  # this example is enough for CentOS 5
  class { 'logstash::config':
    logstash_home => '/opt/logstash',
    logstash_jar_provider => 'http',
    logstash_transport => 'redis',
    redis_provider     => 'package',
    elasticsearch_provider => 'embedded',
  }
  # there is a redis RPM here:
  yumrepo { 'yum.mccartney.ie':
    baseurl  => 'http://yum.mccartney.ie',
    descr    => 'redis for el',
    gpgcheck => 0,
  }
```
Then just apply the required classes to each node:
```puppet
  # indexer/storage node
  class { 'logstash::indexer': }
  # use this class to provide transport that matches what we want, optional
  class { 'logstash::redis': }
  
  # straight log shipper only
  class { 'logstash::shipper': }

  # web interface
  class { 'logstash::web': }
```

### Shipper configuration
Different configuration strategies are available to generate the shipper configuration file. 
#### Default
This strategy tracks events in the syslog format. The monitored log files can be defined in the $config_params
parameter hash by setting a "logfiles" key together with a CSV-string containing the logfiles as value.

The default strategy is used if no configuration parameters were passed to the shipper class.
```puppet
  # Default configuration strategy
  class { 'logstash::shipper':
    config_strategy => 'logstash::shipper::defaultconfig',
    config_params   => {
      logfiles  => '"/var/log/messages", "/var/log/syslog", "/var/log/*.log"'
    }    
  }
```

#### Shared
The shared configuration strategy enables other Puppet modules to add configuration snippets to the shipper configuration. All snippets are later concatenated to one shipper configuration file.

The shared configuration strategy is using Puppet-Concat (see https://github.com/ripienaar/puppet-concat). Please make sure that the Puppet-Concat module is available in the modulepath.
```puppet
  class { 'logstash::shipper':
    config_strategy => 'logstash::shipper::sharedconfig',
    config_params   => {}
  }
```

Other modules can use defines to add input, output or filter snippets to the shipper configuration.
The define name should contain the path to the template file which contains the configuration snippet.
Alternativelly, the template path can be set with the template parameter.
```puppet
  # add a filter configuration
  logstash::shipper::sharedconfig::add_filter { 'mymodule/logstash/shipper-filter.conf.erb': }

  # add an input configuration
  logstash::shipper::sharedconfig::add_input { 'mymodule/logstash/shipper-input.conf.erb': } 

  # add an output configuration
  logstash::shipper::sharedconfig::add_output { 'a_custom_name':
    template => 'mymodule/logstash/shipper-output.conf.erb'
  }
```

###Sample config for Ubuntu Precise (12.04)
```puppet
class { 'logstash::config':
  logstash_home          => '/opt/logstash',
  logstash_jar_provider  => 'http',             # pull down the jar over http
  logstash_transport     => 'redis',            # configure redis as the transport
  redis_provider         => 'package',          # install redis from native package please
  redis_package          => 'redis-server',     # package name for this platform
  redis_version          => '',                 # package-version doesn't work with apt/deb
  elasticsearch_provider => 'embedded',         # we'll run ES inside out logstash JVM
  java_provider          => 'package',          # install java for me please, from a package
  java_package           => 'openjdk-6-jdk',    # package name on this platform
  java_home              => '/usr/lib/jvm/java-6-openjdk-amd64',
                                                # JAVA_HOME for your chosen JDK
}
```

###Sample config for Debian Squeeze (6)
```puppet
class { 'logstash::config':
  logstash_home          => '/opt/logstash',
  logstash_jar_provider  => 'http',
  logstash_transport     => 'redis',
  redis_provider         => 'external',		# Debian 6 ships with redis-server-1.2.6, 
						# which doesn't support BLPOP, so you'll have 
						# provide your own redis-server
  elasticsearch_provider => 'embedded',         # we'll run ES inside out logstash JVM
  java_provider          => 'package',          # install java for me please, from a package
  java_package           => 'openjdk-6-jdk',    # package name on this platform
  java_home              => '/usr/lib/jvm/java-6-openjdk',
                                                # JAVA_HOME for your chosen JDK
}
```
##Configuration Detail##

Many of the configuration defaults come from the original behaviour of Kris Buytaert's original module, which this started out as a fork of.



#Credit#
Based on lots of original work by Kris Buytaert & Joe McDonagh 
https://github.com/KrisBuytaert/puppet-logstash
https://github.com/thesilentpenguin/puppet-logstash

