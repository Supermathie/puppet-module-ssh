# Install the packages necessary to run an SSH server.  Currently supports
# Debian and RHEL/CentOS.  Add other distributions as required.
#
class ssh::packages {
	noop { "ssh/packages/installed": }

	case $::operatingsystem {
		"RedHat", "CentOS": {
			$ssh_package = "openssh"
		}
		"Debian", "Ubuntu": {
			$ssh_package = "openssh-server"
		}
		default: {
			fail("Unsupported \$::operatingsystem '${::operatingsystem}'; please improve ssh::packages")
		}
	}

	package { $ssh_package:
		before => Noop["ssh/packages/installed"];
	}
}
