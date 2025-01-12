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
    cp -r /ganglia_conf/ganglia.conf /etc/httpd/conf.d/ganglia.conf

    groupadd -r ganglia_user && useradd -r -g ganglia_user ganglia_user
    echo "ganglia_user:guser@@123" | chpasswd
    sed -i '34i Cmnd_Alias GANG_SERVICES = /usr/sbin/httpd, /usr/sbin/gmetad, /usr/sbin/gmond, /entrypoint.sh' /etc/sudoers
    sed -i '101i ganglia_user ALL=(ALL) NOPASSWD: GANG_SERVICES' /etc/sudoers
    # Start supervisord to manage services
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisord.conf
    touch /root/CONFIGURED
    su - ganglia_user

fi
   
