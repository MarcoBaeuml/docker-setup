#!/bin/bash

install_docker() {
	#download Docker using the official Docker download script
	curl -sS https://get.docker.com | bash &> /dev/null &
	loading_animation "Installing docker:" "\033[0;32mfinished\033[0m"
	echo $(docker -v)
}

install_docker_compose()   {
	# get the latest version from the release page at GitHub
	VERSION=$(curl -sS https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d') &&
	# download Docker compose plugin
	curl -sSL -o /usr/local/lib/docker/cli-plugins/docker-compose --create-dirs https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-linux-$(uname -p) &&
	chmod +x /usr/local/lib/docker/cli-plugins/docker-compose &
	loading_animation "Installing docker compose:" "\033[0;32mfinished\033[0m"
	echo $(docker compose version)
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

install_docker
install_docker_compose
