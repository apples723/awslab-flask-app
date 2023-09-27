#!/bin/bash
echo "setting up instance....."
root_app_dir=$(dirname ${PWD%/*})
echo "installing docker....."
curl -fsSL https://get.docker.com -o get-docker.sh 
chmod +x get-docker.sh  
sudo ./get-docker.sh > /dev/null
rm get-docker.sh
echo "installing docker-compose v1"
sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "installing aws cli..."
sudo apt install unzip -y > /dev/null
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
rm awscliv2.zip
sudo ./aws/install
rm -rf aws
git clone https://github.com/apples723/awslab-flask-app.git
echo "installing pip3 and requirements..."
sudo apt install python3-pip -y > /dev/null
pip3 install -r "awslab-flask-app/flask-app/requirements.txt"
chmod +x /awslab-flask-app/build/scripts/start.sh
./awslab-flask-app/build/scripts/start.sh