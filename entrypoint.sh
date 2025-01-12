#!/bin/bash

if [ -f /root/CONFIGURED ]; then
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisord.conf
else
    # Replace the default HTTP port in the Apache configuration
    if [[ -n "$PORT" ]]; then
      sed -i -e "s|Listen 80|Listen $PORT|g" /etc/httpd/conf/httpd.conf
      echo "Apache configuration updated to listen on port $PORT."
    else
      echo "PORT environment variable is not set. Using the default configuration."
    fi
    # Generate configuration files from templates
    envsubst < /ganglia_conf/gmetad.conf.template > /etc/ganglia/gmetad.conf
    envsubst < /ganglia_conf/gmond.conf.template > /etc/ganglia/gmond.conf
    # Start supervisord to manage services
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisord.conf
    touch /root/CONFIGURED

fi
   
