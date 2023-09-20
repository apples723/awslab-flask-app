mkdir dev \
cd dev
curl -fsSL https://get.docker.com -o get-docker.sh \
chmod +x get-docker.sh \
sudo ./get-docker.sh 
sudo docker run -p 8000:8000 apples723/awslab-flask-app:v0.3 
sudo docker run -p 80:80 -p 443:443 apples723/caddy-auth:v2-dns