Facter.add(:openssh_server_installed) do
	setcode do
		!(Facter::Core::Execution.exec("which sshd") == "")
	end
end
