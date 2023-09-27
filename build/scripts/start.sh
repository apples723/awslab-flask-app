sudo docker network create caddy
sudo docker volume create caddy_data
sudo docker volume create caddy_config
sudo docker-compose -f /awslab-flask-app/docker-compose.yaml up -d
echo "waiting for flask app to start..."
sleep 10
sudo docker-compose -f /awslab-flask-app/caddy/docker-compose.yaml up -d