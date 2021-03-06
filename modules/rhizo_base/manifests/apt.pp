# Class: rhizo_base::apt
#
# This module manages the apt repositories
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#

class rhizo_base::apt {
  contain "rhizo_base::apt::$operatingsystem"
}

class rhizo_base::apt::common {

  $osmo_repo = hiera('rhizo::osmo_repo', 'latest')

  class { '::apt':
     update => {
       frequency => 'weekly',
     },
  }

  file { '/etc/apt/apt.conf.d/90unsigned':
      ensure  => present,
      content => 'APT::Get::AllowUnauthenticated "true";',
    }

  apt::source { 'rhizomatica':
      location          => 'http://dev.rhizomatica.org/ubuntu/',
      release           => 'precise',
      repos             => 'main',
      include  => {
        'src' => false,
        'deb' => true,
      },
      require           => File['/etc/apt/apt.conf.d/90unsigned'],
    }

  apt::source { 'rhizo':
      location          => 'http://repo.rhizomatica.org/ubuntu/',
      release           => 'precise',
      repos             => 'main',
      include  => {
        'src' => false,
        'deb' => true,
      },
      require           => File['/etc/apt/apt.conf.d/90unsigned'],
    }

}

class rhizo_base::apt::ubuntu inherits rhizo_base::apt::common {

  apt::ppa { 'ppa:keithw/mosh': }
  apt::ppa { 'ppa:ondrej/php': }
  apt::ppa { 'ppa:ondrej/apache2': }

  apt::source { 'nodesource':
      location    => 'https://deb.nodesource.com/node_0.10',
      release     => 'precise',
      repos       => 'main',
      key         => {
        'id'      => '68576280',
        'source'  => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
       }
    }
}

class rhizo_base::apt::debian inherits rhizo_base::apt::common {

  package {'apt-transport-https':
      ensure  => installed,
    }

  apt::source { 'freeswitch':
      location    => 'http://files.freeswitch.org/repo/deb/freeswitch-1.6/',
      release     => 'jessie',
      repos       => 'main',
      key         => {
         'id'     => '20B06EE621AB150D40F6079FD76EDC7725E010CF',
         'source' => 'http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub'
       }
    }

  apt::source { 'nodesource':
      location    => 'https://deb.nodesource.com/node_0.10',
      release     => 'jessie',
      repos       => 'main',
      key         => {
        'id'      => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
        'source'  => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
      },
      require     => Package['apt-transport-https'],
    }

  apt::source { 'irontec':
      location    => 'http://packages.irontec.com/debian',
      release     => 'stretch',
      repos       => 'main',
      key         => {
        'id'      => '4FF7139B43073A436D8C2C4F90D20F5ED8C20040',
        'source'  => 'http://packages.irontec.com/public.key'
       }
    }

  apt::source { 'rhizo-jessie':
      location    => 'http://repo.rhizomatica.org/debian/',
      release     => 'jessie',
      repos       => 'main',
      allow_unsigned => true,
      require     => File['/etc/apt/apt.conf.d/90unsigned'],
    }

  apt::source { 'osmocom':
      location    => "http://download.opensuse.org/repositories/network:/osmocom:/${osmo_repo}/Debian_9.0/",
      release     => './',
      repos       => '',
      notify      => Exec['apt_update'],
      key         => {
        'id'      => '0080689BE757A876CB7DC26962EB1A0917280DDF',
        'source'  => "http://download.opensuse.org/repositories/network:/osmocom:/${osmo_repo}/Debian_9.0/Release.key"
       }
    }

   file { [ '/etc/apt/sources.list.d/osmocom-latest.list',
            '/etc/apt/sources.list.d/osmocom-nightly.list' ]:
      ensure     => absent,
    }
}
