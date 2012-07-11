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
 * on the system.  In order to change what puppet code is run on a partiular
 * server, the "profiles" property should be used.
 */
node default {

  # This assumes the puppet-manifest-core has been added to the core directory.
  import "core/*.pp"
  include config::common

  # We don't know if Hiera is ready yet.
  $common_config = $::hiera_ready ? {
    true    => hiera('hiera_common_config'),
    default => $config::common::hiera_common_config,
  }
  notice "Hiera ready: ${::hiera_ready}"
  notice "Common configuration file: ${common_config}"

  if ! $::hiera_ready or ! exists($common_config) {
    notice "Bootstrapping server"

    # We require Hiera and a valid configuration.
    include bootstrap
  }
  else {
    import "capabilities/*.pp"
    import "profiles/*.pp"

    include base
    hiera_include('profiles')
  }
}
