#!/bin/bash

set -e

trap 'echo "An error occurred. Script terminated." >&2' ERR

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt update
sudo apt install python3-vcstool postgresql -y

mkdir -p rmf-src && mkdir -p rmf-web-src

vcs import rmf-src < rmf/rmf.repos
vcs import rmf-web-src < rmf-web/rmf-web.repos

ROS_DISTRO="${ROS_DISTRO:-humble}"

docker build -f rmf/builder-rosdep.Dockerfile -t rmf-hamal/rmf_deployment/builder-rosdep .
docker build -f rmf/rmf.Dockerfile -t rmf-hamal/rmf_deployment/rmf .
docker build -f rmf-web/builder-rmf-web.Dockerfile -t rmf-hamal/rmf_deployment/builder-rmf-web .
docker build -f rmf-web/rmf-web-rmf-server.Dockerfile -t rmf-hamal/rmf_deployment/rmf-web-rmf-server .
docker build -f rmf-web/rmf-web-dashboard.Dockerfile -t rmf-hamal/rmf_deployment/rmf-web-dashboard .

echo "Script successfully completed."
