#!/bin/bash

PORT=3429 # Port to run the server on
echo "EXTERNAL_PORT=$PORT" >.env

if ! [ -x "$(command -v docker)" ]; then
    printf "\033[0;34mInstalling docker...\e[0m"
    if [ -f /etc/debian_version ]; then
        sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Syu docker
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager \
            --add-repo \
            https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install docker-ce docker-ce-cli containerd.io
    fi
    printf "\033[0;32m - success\e[0m\n"
else
    printf "\033[0;32mDocker is already installed\e[0m\n"
fi

printf "\033[0;34mDownloading configuration files...\e[0m"
if [ -f "Dockerfile" ]; then
    rm Dockerfile
fi
wget -q https://github.com/hikariatama/Hikka/raw/master/Dockerfile
if [ -f "docker-compose.yml" ]; then
    rm docker-compose.yml
fi
wget -q https://github.com/hikariatama/Hikka/raw/master/docker-compose.yml
printf "\033[0;32m - success\e[0m\n"

printf "\033[0;34mBuilding docker image...\e[0m"
docker-compose up -d --build 1>/dev/null 2>&1
printf "\033[0;32m - success\e[0m\n"

printf "\033[0;32mFollow this url to continue installation:\e[0m\n"
ssh "-o StrictHostKeyChecking=no" "-R 80:127.0.0.1:$PORT" "nokey@localhost.run" 2>&1 | grep "tunneled"
