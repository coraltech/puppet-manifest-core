Puppet and JSON configurations are aggregated from the following options based
on the reference Hiera configuration below.

This is just an example.  Real configurations can be changed through Hiera itself
or the config::common class in common.pp.

--------------------------------------------------------------------------------
>> Hiera reference configuration:

---
:backends:
  - json
  - puppet

:hierarchy:
  - "%{hostname}"     # Individual hostname of server
  - "%{location}"     # Location, possibly data center
  - "%{environment}"  # development, staging, qa, production, etc...
  - common

:json:
  :datadir: /var/git/config.git

:puppet:
  :datasource: config


--------------------------------------------------------------------------------
>> Hiera search path: (based on above configuration)

# Private / Automated
json> /var/git/config.git/{hostname}.json
json> /var/git/config.git/{location}.json
json> /var/git/config.git/{environment}.json
json> /var/git/config.git/common.json

# Public / Manual
puppet> config::{hostname}
puppet> config::{location}
puppet> config::{environment}
puppet> config::common
puppet> {module}::config
