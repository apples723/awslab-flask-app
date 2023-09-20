sudo docker-compose -f /home/ubuntu/dev/awslab-flask-app/docker-compose.yaml up -d
sleep 10
echo "waiting for flask app to starting...."
sudo docker-compose up -d /home/ubuntu/dev/awslab-flask-app/caddy/docker-compose.yaml