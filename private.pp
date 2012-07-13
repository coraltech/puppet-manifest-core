/**
 * Configurations that are recommended to be replaced by private data that
 * must be included in some default form in this repository because they are
 * required for the bootstrap process.
 *
 * These are separated out from data::common to make it easier to merge in
 * upstream changes.
 */
class data::private {

  #-----------------------------------------------------------------------------

  $git_init_password = '' # No password (initially unless overriden in sub repo)

  $puppet_source     = 'git://github.com/coraltech/puppet-lib.git'
}
