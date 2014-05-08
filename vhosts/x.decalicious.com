x.decalicious.com


#----------------------------------------------------------------------------------------------------------------------------------------------------


   # ----------------------------------------------------------
   #    X.Decalicious.com/x (Static Content | CDN PULL URL)
   # ----------------------------------------------------------
   server {

    # SERVER SPECIFIC SETTINGS
    listen                80;
    server_name           x.decalicious.com;
    root                  /usr/share/nginx/sites/decalicious-down/;
    keepalive_timeout     5s;
    allow                 all;
    server_tokens         off; 
    more_clear_headers    'Cache-Control';

    # Show Default Local Page for items outside of X
    location / {
      more_set_headers      "X-INFO: Forbidden";      
      break;
    }

   # ----------------------------------------------------------
   #       x.Decalicious.com/s3 (Static Content Amazon S3)
   # ----------------------------------------------------------
    location ~* ^/x/s3/(.*) {

      set $s3_bucket           'decalicious.s3.amazonaws.com';
      set $url_full            '$1';

      # HEADERS
      more_set_headers          "Server: S3-DECALS";
      # CACHE BROWSER 425 DAYS (36720000) | CDN EDGE 30 DAYS (262800)
      add_header                Cache-Control "no-transform,public,max-age=36720000, s-maxage=262800";
      etag                      on;
      expires                   425d;
      
      # Cache File Information
      open_file_cache           max=1000 inactive=500s;
      open_file_cache_valid     600s;
      open_file_cache_errors    on;

      # Gzip
      gzip                      on;
      gzip_vary                 on;
      gzip_http_version         1.0;
      gzip_disable              "MSIE [1-6].(?!.*SV1)";
      gzip_min_length           200;
      gzip_buffers              64 8k;
      gzip_comp_level           3;
      gzip_proxied              any;
      gzip_types                text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript font/ttf font/opentype application/vnd.ms-fontobject image/svg+xml;

      # PROXY SETTINGS
      proxy_set_header          Accept-Encoding "";
      proxy_http_version        1.1;
      proxy_redirect            off;
      proxy_set_header          Host $s3_bucket;
      proxy_set_header          Authorization '';

      proxy_hide_header         x-amz-id-2;
      proxy_hide_header         x-amz-request-id;
      proxy_hide_header         x-amz-meta-tag;
      proxy_hide_header         x-amz-meta-uuid;
      
      proxy_hide_header         Set-Cookie;
      proxy_ignore_headers      "Set-Cookie";
      proxy_buffering           off;
      resolver                  8.8.4.4 8.8.8.8 valid=300s;
      resolver_timeout          10s;
      proxy_pass                http://$s3_bucket/$url_full;
      proxy_temp_path           /usr/share/nginx/temp;

      # PROXY CACHING
      proxy_cache               STATIC;
      proxy_cache_valid         200 302 1d;
      proxy_cache_valid         404     1m;
      proxy_cache_use_stale     error timeout invalid_header updating
      http_500 http_502 http_503 http_504;

      #HTTP ERRORS LOCALLY 
      proxy_intercept_errors on; 
      error_page 500 502 503 504 =503 /maintenance.html;
      error_page 404 =404 /404.html;      
      break;
    }



    location ~* /(x/|app/|favicon.ico) {
    
      # HEADERS
      more_set_headers          "Server: X-DECALS";
      # CACHE BROWSER 425 DAYS (36720000) | CDN EDGE 30 DAYS (262800)
      add_header                Cache-Control "no-transform,public,max-age=36720000, s-maxage=262800";
      etag                      on;
      expires                   425d;
      
      # Cache File Information
      open_file_cache           max=1000 inactive=500s;
      open_file_cache_valid     600s;
      open_file_cache_errors    on;

      # Gzip
      gzip                      on;
     #gzip_vary                 on;
      gzip_http_version         1.1;
      gzip_disable              "MSIE [1-6].(?!.*SV1)";
      gzip_min_length           1;
      gzip_buffers              64 8k;
      gzip_comp_level           3;
      gzip_proxied              any;
     #gzip_types                text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript;
      gzip_types                text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript font/ttf font/opentype application/vnd.ms-fontobject image/svg+xml;

 
      # PROXY SETTINGS
      proxy_http_version        1.1;
      proxy_redirect            off;
      proxy_set_header          Host              "www.decalicious.com";
     #proxy_set_header          X-Real-IP         $remote_addr;
     #proxy_set_header          X-Forwarded-For   $proxy_add_x_forwarded_for;
     #proxy_set_header          X-Forwarded-Proto $scheme;
      proxy_pass                http://iis-servers-decalicious;
      proxy_temp_path           /usr/share/nginx/temp;
     #proxy_connect_timeout     5;
     #proxy_read_timeout        240;

      # PROXY CACHING
      proxy_cache               STATIC;
      proxy_cache_valid         200 302 1d;
      proxy_cache_valid         404     1m;
      proxy_cache_use_stale     error timeout invalid_header updating
      http_500 http_502 http_503 http_504;

      #HTTP ERRORS LOCALLY 
      proxy_intercept_errors on; 
      error_page 500 502 503 504 =503 /maintenance.html;
      #error_page 404 =404 /404.html;      
      break;
    }

    # ERROR PAGE - DOWN FOR MAINTENANCE
    location  ^~ /maintenance.html {
      root   /usr/share/nginx/sites/decalicious-down/;
      index  maintenance.html index.html index.htm;
      allow all;
    }

    # EROR PAGE - LOCAL 404 PAGE
    location  ^~ /404.html {
      root   /usr/share/nginx/sites/decalicious-down/;
      index  404.html index.html index.htm;
      allow all;
    }

    # LOCAL ERROR PAGE SCRIPTS AND IMAGES (XS Directory)
    location /xs {
      root   /usr/share/nginx/sites/decalicious-down/;
      allow  all;     
   }

   # ERROR PAGES (LOCAL)
   error_page 404 =404 /usr/share/nginx/sites/decalicious-down/404.html;
   error_page 500 502 503 504 =503 /usr/share/nginx/sites/decalicious-down/maintenance.html;

   # NO LOGGING
   access_log          /dev/null;
   error_log           /dev/null;
   # DEBUG LOGGING
   #error_log           /var/log/nginx/decalicious.com.error.log ;
   #access_log          /var/log/nginx/decalicious.com.log ;

  }
