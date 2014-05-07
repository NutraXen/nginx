#!/bin/bash
cd /XEN-TOOLS/GIT-PULL-HERE 
git pull
rm -rf /usr/share/nginx/cache*
/etc/init.d/nginx reload
echo ""
echo "Nginx Reloaded wtih Latest GIT "
echo ""