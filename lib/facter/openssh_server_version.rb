Facter.add(:openssh_server_version) do
	confine :openssh_server_installed => true

	setcode do
		output = `sshd -V 2>&1`  # This doesn't *actually* ask SSH to print
		                         # the version, but the error output has what
		                         # we want anyway

		if output =~ /^OpenSSH_(\d+\.\d+(p\d+)?)/
			$1
		else
			nil
		end
	end
end
