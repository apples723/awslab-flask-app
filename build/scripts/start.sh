sudo docker-compose -f /home/ubuntu/dev/awslab-flask-app/docker-compose.yaml up -d
echo "waiting for flask app to start..."
sleep 10
sudo docker-compose -f /home/ubuntu/dev/awslab-flask-app/caddy/docker-compose.yaml up -d