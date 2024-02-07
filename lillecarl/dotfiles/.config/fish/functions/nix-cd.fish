function nix-cd
	set -f pkg $argv[1]
	set -f shell_path (nix shell "nixpkgs#$pkg" --command sh -c 'echo $PATH')
	set -f shell_path_list (echo $shell_path | string split ':')
	cd $shell_path_list[1] > /dev/null || cd (dirname $shell_path_list[1]) > /dev/null || echo "Wtf"
end
