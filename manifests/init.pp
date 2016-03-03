# Install the Vault application from HashiCorp
class vault(
  $ensure   = present,
  $root     = $vault::params::root,
  $user     = $vault::params::user,
  $version  = $vault::params::version
  ) inherits vault::params {

  case $ensure {
    present: {
      $download_uri = "https://releases.hashicorp.com/vault/${version}/vault_${version}_darwin_amd64.zip"

      $install_command = join([
        # blow away any previous attempts
        'rm -rf /tmp/vault',
        # download the zip to tmp
        "curl ${download_uri} -L > /tmp/vault-v${version}.zip",
        # extract the zip to tmp spot
        'mkdir /tmp/vault',
        "unzip -o /tmp/vault-v${version}.zip -d /tmp/vault",
        # blow away an existing version if there is one
        "rm -rf ${root}",
        # move the directory to the root
        "mv /tmp/vault ${root}",
        # chown it
        "chown -R ${user} ${root}"
      ], ' && ')

      exec {
        "install vault v${version}":
          command => $install_command,
          unless  => "test -d ${root} && test -x ${root}/vault && ${root}/vault --version | grep 'Vault'",
          user    => $user,
      }

      if $::operatingsystem == 'Darwin' {
        include boxen::config

        boxen::env_script { 'vault':
          content  => template('vault/env.sh.erb'),
          priority => 'lower',
        }

        file { "${boxen::config::envdir}/vault.sh":
          ensure => absent,
        }
      }
    }

    absent: {
      file{ $root:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }

    default: {
      fail('Ensure must be present or absent')
    }
  }
}
