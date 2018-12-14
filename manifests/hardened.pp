# Configure an SSH server to remove weak ciphers, MACs, and key exchange
# algorithms.  Also remove low-grade DH moduli.
#
# Based on https://stribika.github.io/2015/01/04/secure-secure-shell.html
#
class ssh::hardened {
	if 0 + $::openssh_server_version_major < 6 or
	   (0 + $::openssh_server_version_major == 6 and 0 + $::openssh_server_version_minor < 4) {
		warning "OpenSSH v6.4 or greater is required for hardening"
	} else {
		Exec {
			notify => Service["ssh"],
		}

		# Augeas support in Puppet is so bad that, for lists like this that need
		# to have both *exactly* the right values *and* those values need to be
		# in an exact order, it's practically impossible to do via Augeas.  So,
		# we do it the hard way
		$cipher_list = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
		$mac_list    = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com"
		$kex_list    = "curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256"

		exec {
			"set sshd cipher list":
				user    => "root",
				command => "/bin/echo Ciphers ${cipher_list} >>/etc/ssh/sshd_config",
				unless  => "/bin/grep -q ^Ciphers /etc/ssh/sshd_config";
			"set sshd MACs list":
				user    => "root",
				command => "/bin/echo MACs ${mac_list} >>/etc/ssh/sshd_config",
				unless  => "/bin/grep -q ^MACs /etc/ssh/sshd_config";
			"set sshd KEX list":
				user    => "root",
				command => "/bin/echo KexAlgorithms ${kex_list} >>/etc/ssh/sshd_config",
				unless  => "/bin/grep -q ^KexAlgorithms /etc/ssh/sshd_config";
			"modify sshd cipher list":
				user    => "root",
				command => "/bin/sed -i 's/^Ciphers .*$/Ciphers ${cipher_list}/' /etc/ssh/sshd_config",
				unless  => "/usr/bin/test \"$(grep ^Ciphers /etc/ssh/sshd_config)\" = \"Ciphers ${cipher_list}\"";
			"modify sshd MACs list":
				user    => "root",
				command => "/bin/sed -i 's/^MACs .*$/MACs ${mac_list}/' /etc/ssh/sshd_config",
				unless  => "/usr/bin/test \"$(grep ^MACs /etc/ssh/sshd_config)\" = \"MACs ${mac_list}\"";
			"modify sshd KEX list":
				user    => "root",
				command => "/bin/sed -i 's/^KexAlgorithms .*$/KexAlgorithms ${kex_list}/' /etc/ssh/sshd_config",
				unless  => "/usr/bin/test \"$(grep ^KexAlgorithms /etc/ssh/sshd_config)\" = \"KexAlgorithms ${kex_list}\"";
		}

		file { "/etc/ssh/moduli":
			ensure => file,
			source => "puppet:///modules/ssh/etc/ssh/moduli",
			owner  => "root",
			group  => "root",
			mode   => "0444",
			notify => Service["ssh"],
		}
	}
}
