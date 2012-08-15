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

  if ! ( $::hiera_ready and exists(global_param('hiera_common_config')) ) {
    $config_address = global_param('base_config_address')

    notice "Bootstrapping server"
    notice "Push configurations to: ${config_address}"

    # We require Hiera and a valid configuration.
    include bootstrap
  }
  else {
    import "profiles/*.pp"

    include base

    if ! empty(hiera('profiles', [])) {
      hiera_include('profiles')
    }
  }
}
