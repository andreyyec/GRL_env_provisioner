# Install dependencies
sudo apt update
sudo apt install -y build-essential

#Install node6.0
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt-get install -y nodejs

#Get application code
git clone https://github.com/timeoff-management/application.git timeoff-management

#build and deploy
cd timeoff-management
npm install
npm start &
