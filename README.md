Nginx Server As Reverse Proxy For IIS
=====================================

<h2>Download, Build & Install NginX 1.6 custom: <br>Azure / Aws Servers</h2>
<ul>
	<li>Creates /XEN-TOOLS/ director at root of server</li>
	<li>Creates custom install of nginx</li>
	<li>Pulls sites / vhosts from within this repo & configures them</li>
</ul>

<h3>Instructions</h3>
<ul>
	<li>Fresh install Ubuntu 12.04 on Azure Server</li>
	<li>Become Root by typing: sudo su </li>
	<li>Move to temp directory: cd /tmp </li>
	<li>Download installer script: wget wget https://raw.githubusercontent.com/NutraXen/nginx/master/bash/install-nginx-custom.sh</li>
	<li>Begin Installer: sudo bash install-nginx-custom.sh</li>
</ul>

<h5>Important!</h5>
<i>Note: The git repository /usr/share/nginx/ is removed after script completes.<br>
to get latest version type the following commands:<br><br>
service nginx stop<br>
cd /usr/share<br>
rm -r nginx<br>
git clone https://github.com/NutraXen/nginx.git<br>
/etc/init.d/nginx reload<br>
service nginx start<br>
</i>