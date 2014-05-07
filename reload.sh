#!/bin/bash
cd /XEN-TOOLS/GIT-PULL-HERE 
git pull
rm -rf /usr/share/nginx/cache*
/etc/init.d/nginx reload
cd /var/log/nginx
rm r *
cd /XEN-TOOLS/GIT-PULL-HERE 
echo ""
echo "Nginx Reloaded wtih Latest GIT "
echo ""