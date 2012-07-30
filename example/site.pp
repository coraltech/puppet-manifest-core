/**
 * Gateway manifest to all Puppet classes.
 *
 * Note: This is the only node in this system.  We use it to dynamically
 * bootstrap or load and manage classes (profiles).
 *
 * This should allow the server to configure it's own profiles in the future.
 *
 * TO USE:
 *
 * Copy this file to your root manifest directory.  It should be the only node
 * on the system.  In order to change what puppet code is run on a particular
 * server, the "profiles" property should be used.
 */
node default {

  # This assumes the puppet-manifest-core has been added to the core directory.
  import "core/*.pp"
  include data::common

  debug "Hiera ready: ${::hiera_ready}"
  debug "Common configuration file: ${data::common::os_hiera_common_config}"

  if ! ( $::hiera_ready and exists($data::common::os_hiera_common_config) ) {
    notice "Bootstrapping server"

    # We require Hiera and a valid configuration.
    include bootstrap
  }
  else {
    import "profiles/*.pp"

    include base
    hiera_include('profiles')
  }
}
