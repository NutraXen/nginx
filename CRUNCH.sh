#!/bin/bash
cd /XEN-TOOLS/GIT-PULL-HERE 
git pull
echo "*************************"
echo "  1 - Git Pulled New Files"
echo "*************************"

cd /usr/share/nginx/cache
rm -r *
sudo mkdir /usr/share/nginx/cache/a
sudo mkdir /usr/share/nginx/cache/b
sudo mkdir /usr/share/nginx/cache/c
sudo mkdir /usr/share/nginx/cache/d
sudo mkdir /usr/share/nginx/cache/e

cd /var/log/nginx
rm r *
echo "*************************"
echo "  2 - Clearned Nginx Cache & LOGS"
echo "*************************"

cd /etc/nginx/
rm nginx.custom.conf
cp /usr/share/nginx/etc-config/nginx.custom.conf /etc/nginx/nginx.custom.conf
echo "***********************************************"
echo "  3 - Reloaded Nginx.custom.conf from repo"
echo "***********************************************"

cd /XEN-TOOLS/GIT-PULL-HERE 

/etc/init.d/nginx reload
service nginx restart

echo ""
echo "DONE "
echo ""
echo ""