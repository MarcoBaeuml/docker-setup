#!/bin/bash

install_docker() {
	# download Docker using the official Docker download script
	curl -sS https://get.docker.com | bash &> /dev/null &
	loading_animation "Installing Docker:" "\033[0;32mfinished\033[0m"
	echo $(docker -v)
}

install_docker_compose() {
	# get the latest version from the release page at GitHub
	( VERSION=$(curl -sS https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
	# download Docker compose V2 plugin
	curl -sSL -o /usr/local/lib/docker/cli-plugins/docker-compose --create-dirs https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-linux-$(uname -m)
	chmod +x /usr/local/lib/docker/cli-plugins/docker-compose ) &
	loading_animation "Installing Docker compose:" "\033[0;32mfinished\033[0m"
	echo $(docker compose version)
}

remove_docker() {
	( dpkg -l | grep -i docker
	apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli
	apt-get autoremove -y --purge docker-engine docker docker.io docker-ce
	rm -rf /var/lib/docker /etc/docker
	rm /etc/apparmor.d/docker
	groupdel docker
	rm -rf /var/run/docker.sock
	rm -rf /usr/local/bin/docker-compose
	rm -rf /usr/local/lib/docker/
	rm -rf ~/.docker
	rm -rf /usr/libexec/docker ) &> /dev/null &
	loading_animation "Removing Docker + Docker compose:" "\033[0;32mfinished\033[0m"
}

loading_animation(){
	pid=$! 
	spin=( '-' "\\" '|' '/' )
	echo -n "$1 ${spin[0]}"
	while kill -0 $pid &> /dev/null
	do
		for i in "${spin[@]}"
		do
			echo -ne "\b$i"
			sleep 0.2
		done
	done
	echo -ne "\b$2\n"
}

dockerExistMenu() {
	echo "It looks like Docker is already installed."
	echo ""
	echo "What do you want to do?"
	echo "   1) Reinstall Docker"
	echo "   2) Remove Docker"
	echo "   3) Exit"
	echo ""
	until [[ $MENU_OPTION =~ ^[1-3]$ ]]; do
		read -rp "Select an option [1-3]: " MENU_OPTION
	done
	case $MENU_OPTION in
	1)
		prompt_confirm "Sure you want to reinstall Docker + Docker compose"
		remove_docker
		install_docker
		install_docker_compose
		;;
	2)
		prompt_confirm "Sure you want to remove Docker + Docker compose"
		remove_docker
		;;
	3)
		echo "exiting..."
		exit 0
		;;
	esac
}

dockerDoesntExistMenu() {
	echo "This script will install Docker + Docker compose V2 (Plugin)"
	prompt_confirm "Do you want to continue?"
	install_docker
	install_docker_compose
}

prompt_confirm() {
	read -r -p "$1 [y/N] " response
	case "$response" in
		[yY][eE][sS]|[yY]) 
			return 0
			;;
		*)
			echo "exiting..."
			exit 0
			;;
	esac
}

echo "Brilliant decision, Docker is awesome"
echo "The git repository is available at: https://github.com/MarcoBaeuml/docker-setup"
echo ""

if [ -x "$(command -v docker)" ]; then
	dockerExistMenu
else
	dockerDoesntExistMenu
fi
