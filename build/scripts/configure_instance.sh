echo "setting up instance....."
mkdir dev
echo "installing docker....."
curl -fsSL https://get.docker.com -o get-docker.sh \
chmod +x get-docker.sh \ 
sudo ./get-docker.sh > /dev/null
echo "installing aws cli..."
sudo apt install unzip -y > /dev/null
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
