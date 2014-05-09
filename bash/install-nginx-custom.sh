#!/bin/bash

# TODO AFTER INSTALL
# INSTALL PHP (FAST CGI)
# INSTALL MYSQL

# QUICK INSTALL INSTRUCTIONS:
# cd /tmp
# wget https://raw.githubusercontent.com/NutraXen/nginx/master/bash/install-nginx-custom.sh
# sudo bash install-nginx-custom.sh


#Remove Existing NGINX Cust in case it exists. 
sudo rm -f -R /usr/share/nginx && rm -f /usr/sbin/nginx
sudo rm /etc/init.d/nginx
sudo rm -f -R /etc/nginx
rm -r /XEN-TOOLS/GIT-PULL-HERE
rm -r /var/log/nginx
rm -r /var/lib/nginx
rm -r /var/cache/nginx

# Customize your build flags here.
export CFLAGS="-pipe -march=nocona -mtune=i686 -O2 -msse -mmmx -msse2 -msse3 -mfpmath=sse"

# Determine the number of processors available to us for configuring scripts.
CORES=`grep processor /proc/cpuinfo | wc -l`
if ! [[ "$CORES" =~ ^[0-9]+$ ]] || [[ "$CORES" -lt 1 ]]; then
        CORES=1
fi

# GET UPDATES 
echo "Getting System Updates..."
sudo apt-get update && sudo apt-get autoremove && sudo apt-get autoclean
sudo apt-get -y install htop unzip git build-essential libpcre3 libpcre3-dev libssl-dev checkinstall automake





#/backup firewall/
cd /
rm -r XEN-TOOLS
mkdir XEN-TOOLS
cd XEN-TOOLS
mkdir BASH-SCRIPTS
cd /XEN-TOOLS/BASH-SCRIPTS
cd /XEN-TOOLS
mkdir FIREWALL
echo "created directories /XEN-TOOLS"
iptables-save > /XEN-TOOLS/FIREWALL/firewall.conf
iptables-save > /XEN-TOOLS/FIREWALL/firewall.original.conf
echo "Firewall Backed Up"
cd /XEN-TOOLS
mkdir SSL-BACKUPS


sudo apt-get update
sudo apt-get -y install zip
sudo apt-get -y install build-essential libxml2-dev libfuse-dev libcurl4-openssl-dev
sudo apt-get -y install htop unzip git build-essential libpcre3 libpcre3-dev libssl-dev checkinstall automake


echo ""
echo "Updates Completed!"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""


# Create directory for Src files.
cd /
mkdir ~/src

# Grab upload progress module.
cd ~/src
rm -r nginx-upload-progress-module
git clone https://github.com/NutraXen/nginx-upload-progress-module

# Grab more-headers module.
rm -r headers-more-nginx-module
git clone https://github.com/NutraXen/headers-more-nginx-module

# Grab the uptsream fair module.
rm -r nginx-upstream-fair
git clone https://github.com/NutraXen/nginx-upstream-fair

# Grab the Upstream Module
rm -r nginx_upstream_check_module
git clone https://github.com/NutraXen/nginx_upstream_check_module

# Grab NginX Substitutions Module
rm -r ngx_http_substitutions_filter_module
git clone https://github.com/NutraXen/ngx_http_substitutions_filter_module


# Grab libunwind
rm -r libunwind-0.99-beta
wget http://download.savannah.gnu.org/releases/libunwind/libunwind-0.99-beta.tar.gz
tar -xzvf libunwind-0.99-beta.tar.gz
rm libunwind-0.99-beta.tar.gz
cd libunwind-0.99-beta
sudo ./configure CFLAGS="-U_FORTIFY_SOURCE -pipe -march=nocona -mtune=i686 -O2 -msse -mmmx -msse2 -msse3 -mfpmath=sse" && sudo make && sudo checkinstall --pkgversion=0.99 --default

# Grab Google's Performance Tools library.
cd ~/src
rm - r gperftools-2.0
wget https://gperftools.googlecode.com/files/gperftools-2.0.tar.gz
tar -xzvf gperftools-2.0.tar.gz
rm gperftools-2.0.tar.gz
cd gperftools-2.0
sudo ./configure CFLAGS="-pipe -march=nocona -mtune=i686 -O2 -msse -mmmx -msse2 -msse3 -mfpmath=sse" && sudo make && sudo checkinstall --default




echo "Downloaded Necessary Nginx Plugins"
echo ""
echo ""
echo ""
echo ""
echo "COMILING NGINX"
echo ""
echo ""


# Compile Nginx.
cd ~/src
wget http://nginx.org/download/nginx-1.6.0.tar.gz
tar -xzvf nginx-1.6.0.tar.gz
rm nginx-1.6.0.tar.gz
cd nginx-1.6.0

# Get New Patch (Suppose to work with 1.5.12)
wget https://raw.githubusercontent.com/NutraXen/patches/master/nginx_upstream_check_module/check_1.5.12.patch


# REQUIRED PATCH FOR UPSTREAM 
#sudo patch -p1 < ~/src/nginx_upstream_check_module/check_1.2.6+.patch
sudo patch -p1 < ~/src/nginx_upstream_check_module/check_1.5.12.patch

sudo ./configure \
--prefix=/usr/share/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/run/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/var/lib/nginx/body \
--http-proxy-temp-path=/var/lib/nginx/proxy \
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
--lock-path=/var/lock/nginx.lock \
--with-cc-opt="-pipe -march=nocona -O2 -msse -mmmx -msse2 -msse3 -mfpmath=sse" \
--with-rtsig_module \
--without-select_module \
--without-poll_module \
--with-file-aio \
--with-ipv6 \
--with-http_ssl_module \
--with-http_spdy_module \
--with-http_realip_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--without-http_ssi_module \
--without-http_userid_module \
--without-http_geo_module \
--without-http_referer_module \
--without-http_uwsgi_module \
--without-http_scgi_module \
--without-http_memcached_module \
--without-http_empty_gif_module \
--without-http_browser_module \
--with-google_perftools_module \
--with-pcre-jit \
--add-module=$HOME/src/headers-more-nginx-module/ \
--add-module=$HOME/src/ngx_http_substitutions_filter_module/ \
--add-module=$HOME/src/nginx_upstream_check_module/ && sudo make && sudo checkinstall --default

sudo /sbin/ldconfig

# Configure nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.custom.conf
sudo sed -i "s/worker_processes  1;/worker_processes $CORES;/" /etc/nginx/nginx.custom.conf

# Install init.d script
sudo wget https://raw.github.com/NutraXen/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo sed -i 's/DAEMON=\/usr\/local\/nginx\/sbin\/nginx/DAEMON=\/usr\/sbin\/nginx/' /etc/init.d/nginx
sudo sed -i 's/lockfile=\/var\/lock\/subsys\/nginx/lockfile=\/var\/lock\/nginx.lock/' /etc/init.d/nginx
sudo sed -i 's/PIDSPATH=\/usr\/local\/nginx\/logs/PIDSPATH=\/run/' /etc/init.d/nginx
sudo sed -i 's/NGINX_CONF_FILE="\/usr\/local\/nginx\/conf\/nginx.conf"/NGINX_CONF_FILE="\/etc\/nginx\/nginx.custom.conf"/' /etc/init.d/nginx
sudo update-rc.d -f nginx defaults

sudo mkdir /var/lib/nginx
sudo mkdir /var/lib/nginx/body
sudo mkdir /etc/nginx/conf.d
sudo mkdir /var/cache/nginx
sudo mkdir /var/cache/nginx/ngx_pagespeed_cache



sudo mkdir /usr/share/nginx/cache
sudo mkdir /usr/share/nginx/cache/a
sudo mkdir /usr/share/nginx/cache/b
sudo mkdir /usr/share/nginx/cache/c
sudo mkdir /usr/share/nginx/cache/d
sudo mkdir /usr/share/nginx/cache/e



sudo service nginx start


echo ""
echo ""
echo "NginX Installed and Started"
echo ""
echo "######################################################"
echo "# SETTING UP INTIAL SITES / CONFIGURATION FOR NGINX"
echo "#######################################################"
echo ""
echo "Stopping NginX"
service nginx stop

# remove old conf file & create working directories
cd /etc/nginx/ 
cp nginx.conf.default nginx.custom.oirginal
rm nginx.conf.default
rm nginx.conf
mkdir /etc/nginx/sites-enabled/
mkdir /etc/nginx/sites-available/
echo "Directories Created"
echo ""

# Clone Default Site from Github / Add it to sites available and enabled.  
cd /usr/share/
rm -r /usr/share/nginx/
git clone https://github.com/NutraXen/nginx.git
echo "Cloned Git Repo - NGINX"
echo ""


# Replace Nginx Config with the one from our git repo (nginx\etc-config\nginx.custom.conf)
echo "Replacing Nginx Configuration"
cd /etc/nginx/
rm nginx.custom.conf
echo "- Removed /etc/nginx/nginx.custom.conf"
cp /usr/share/nginx/etc-config/nginx.custom.conf /etc/nginx/nginx.custom.conf
echo "- Replaced /etc/nginx/nginx.custom.conf with configuration from /usr/share/nginx/etc-config"
echo "-- Nginx now using custom configuraiton from Git Repo"
echo ""
echo ""
cp nginx.custom.conf nginx.custom.backup-from-install

#GET MIME TYPES
echo ""
echo "-- Copying Custom Mime Types (mime.types)  previous version saved as (mime.types.old)"
cp /etc/nginx/mime.types /etc/nginx/mime.types.old
rm /etc/nginx/mime.types
cp /usr/share/nginx/etc-config/mime.types /etc/nginx/mime.types


# Symlink the config files for default site... (This is the site which serves as CDN for Azure)
echo ""
echo "-- Sites Enabled > DEFAULT WEBSITE"
rm /etc/nginx/sites-available/default.conf
ln -s  /usr/share/nginx/vhosts/default.conf /etc/nginx/sites-available/default.conf
rm /etc/nginx/sites-enabled/default.conf
ln -s  /usr/share/nginx/vhosts/default.conf /etc/nginx/sites-enabled/default.conf

# Symlink for NutraXen.com
echo ""
echo "-- Sites Enabled > NUTRAXEN.com"
rm /etc/nginx/sites-available/nutraxen.conf
ln -s  /usr/share/nginx/vhosts/nutraxen.conf /etc/nginx/sites-available/nutraxen.conf
rm /etc/nginx/sites-enabled/nutraxen.conf
ln -s  /usr/share/nginx/vhosts/nutraxen.conf /etc/nginx/sites-enabled/nutraxen.conf

# Symlink for Decalicious.com
echo ""
echo "-- Sites Enabled > DECALICIOUS.com"
rm /etc/nginx/sites-available/decalicious.conf
ln -s  /usr/share/nginx/vhosts/decalicious.conf /etc/nginx/sites-available/decalicious.conf
rm /etc/nginx/sites-enabled/decalicious.conf
ln -s  /usr/share/nginx/vhosts/decalicious.conf /etc/nginx/sites-enabled/decalicious.conf



echo ""
echo "######################################################"
echo "#    CLEANING UP AND CREATING XEN-TOOLS SHORTCUTS"
echo "#######################################################"
echo ""
# Remove git from directory???
echo "Cleaning Up:"
#echo " - Removing Git Directory /usr/share/nginx/nginx-default-site/.git/"
#rm -r /usr/share/nginx/.git/ 
echo " - Moving installer script to /XEN-TOOLS/BASH-SCRIPTS/install-nginx-custom.sh"
cp /tmp/install-nginx-custom.sh /XEN-TOOLS/BASH-SCRIPTS/install-nginx-custom.sh
echo ""

# Create Shortcuts
echo "Creating Shortcuts:"
echo " - XEN-TOOLS/NGINX - parent folder"
cd /XEN-TOOLS/
mkdir NGINX
echo "- XEN-TOOLS/NGINX/server.config - Server Confguration File"
ln -s  /etc/nginx/nginx.custom.conf /XEN-TOOLS/NGINX/server.config
echo "- XEN-TOOLS/NGINX/SERVER - shortcut: /etc/nginx"
ln -s  /etc/nginx/ /XEN-TOOLS/NGINX/SERVER
echo "- XEN-TOOLS/NGINX/VHOSTS - shortcut: /usr/share/nginx/vhosts/ "
ln -s  /usr/share/nginx/vhosts/ /XEN-TOOLS/NGINX/VHOSTS
echo "- XEN-TOOLS/NGINX/SITES-ENABLED - shortcut: /etc/nginx/sites-enabled "
ln -s  /etc/nginx/sites-enabled/ /XEN-TOOLS/NGINX/SITES-ENABLED
echo "- XEN-TOOLS/NGINX/SITES - shortcut: /usr/share/nginx/sites/ "
ln -s  /usr/share/nginx/sites/ /XEN-TOOLS/NGINX/SITES
echo "- XEN-TOOLS/NGINX/_LOGS - shortcut: /var/log/nginx/ "
ln -s  /var/log/nginx/ /XEN-TOOLS/NGINX/_LOGS
echo "- XEN-TOOLS/NGINX/SSL-CERTS - shortcut: /var/log/nginx/ "
ln -s  /usr/share/nginx/ssl-certs/ /XEN-TOOLS/NGINX/SSL-CERTS
ln -s  /usr/share/nginx/ssl-certs/ /etc/nginx/ssl-certs
ln -s  /usr/share/nginx/cache /XEN-TOOLS/NGINX/CACHE

# Create a directory (symlink) for quick git pulls to update this script...
ln -s /usr/share/nginx /XEN-TOOLS/GIT-PULL-HERE



# INSTALL PHP
apt-get -y install php5-fpm php5-cli



# TODO CACHES

echo ""
echo ""
echo "Starting Nginx"
sudo /etc/init.d/nginx reload
sudo service nginx restart
echo ""
echo "All Done!"

echo "IMPORTANT!!!!"
echo "- Please configure nginx sites:"
echo "- changing directory to /XEN-TOOLS/NGINX/VHOSTS to get you started"
cd /XEN-TOOLS/NGINX/VHOSTS

echo "IMPORTANT!!!!"
echo "- Please configure SSL Certificates As Required:"
# Remove this bash script if loaded from tmp directory
rm /tmp/install-nginx-custom.sh