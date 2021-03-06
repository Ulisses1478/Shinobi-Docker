#!/bin/bash
echo "========================================================="
echo "==!! Shinobi : The Open Source CCTV and NVR Solution !!=="
echo "========================================================="
#Detect Ubuntu Version
echo "============="
echo " Detecting Ubuntu Version"
echo "============="
getubuntuversion=$(lsb_release -r | awk '{print $2}' | cut -d . -f1)
echo "============="
echo " Ubuntu Version: $getubuntuversion"
echo "============="
if [ "$getubuntuversion" = "18" ] || [ "$getubuntuversion" > "18" ]; then
    apt install sudo wget -y
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe -y
fi
#create conf.json
if [ ! -e "./conf.json" ]; then
    sudo cp conf.sample.json conf.json
fi
#create super.json
if [ ! -e "./super.json" ]; then
    echo "============="
    echo "Default Superuser : admin@shinobi.video"
    echo "Default Password : admin"
    echo "* You can edit these settings in \"super.json\" located in the Shinobi directory."
    sudo cp super.sample.json super.json
fi
if ! [ -x "$(command -v ifconfig)" ]; then
    echo "============="
    echo "Shinobi - Installing Net-Tools"
    sudo apt install net-tools -y
fi
if ! [ -x "$(command -v node)" ]; then
    echo "============="
    echo "Shinobi - Installing Node.js"
    wget https://deb.nodesource.com/setup_8.x
    chmod +x setup_8.x
    ./setup_8.x
    sudo apt install nodejs -y
else
    echo "Node.js Found..."
    echo "Version : $(node -v)"
fi
if ! [ -x "$(command -v npm)" ]; then
    sudo apt install npm -y
fi
sudo apt install make zip -y
if ! [ -x "$(command -v ffmpeg)" ]; then
    if [ "$getubuntuversion" = "16" ] || [ "$getubuntuversion" < "16" ]; then
        echo "============="
        echo "Shinobi - Get FFMPEG 3.x from ppa:jonathonf/ffmpeg-3"
        sudo add-apt-repository ppa:jonathonf/ffmpeg-3 -y
        sudo apt update -y && sudo apt install ffmpeg libav-tools x264 x265 -y
    else
        echo "============="
        echo "Shinobi - Installing FFMPEG"
        sudo apt install ffmpeg -y
    fi
else
    echo "FFmpeg Found..."
    echo "Version : $(ffmpeg -version)"
fi
    echo "Database Installation..."
sqluser= root
sqlpass= root
        sudo mysql -u $sqluser -p$sqlpass -e "source sql/user.sql" || true
        sudo mysql -u $sqluser -p$sqlpass -e "source sql/framework.sql" || true
echo "============="
echo "Shinobi - Install NPM Libraries"
sudo npm i npm -g
sudo npm install --unsafe-perm
sudo npm audit fix --force
echo "============="
echo "Shinobi - Install PM2"
sudo npm install pm2 -g
echo "Shinobi - Finished"
sudo chmod -R 755 .
touch INSTALL/installed.txt
dos2unix /home/Shinobi/INSTALL/shinobi
ln -s /home/Shinobi/INSTALL/shinobi /usr/bin/shinobi
sudo pm2 start camera.js
sudo pm2 start cron.js
sudo pm2 startup
sudo pm2 save
sudo pm2 list
echo "====================================="
echo "||=====   Install Completed   =====||"
echo "====================================="
echo "|| Login with the Superuser and create a new user!!"
echo "||==================================="
echo "|| Open http://$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'):8080/super in your web browser."
echo "||==================================="
echo "|| Default Superuser : admin@shinobi.video"
echo "|| Default Password : admin"
echo "====================================="
echo "====================================="
