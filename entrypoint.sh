#!/bin/bash

if [ -f /root/CONFIGURED ]; then
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisord.conf
else
    # Check if required environment variables are set
    required_vars=( ROOT_PASSWD GANGLIA_USER GANGLIA_USER_PASSWD PORT GRIDNAME CLUSTERNAME HOSTIP ) 

    for var in "${required_vars[@]}"; do
       if [ -z "${!var}" ]; then
         echo "Error: Environment variable $var is not set." >&2
         exit 1
      fi
    done

    # Replace the default HTTP port in the Apache configuration
    if [[ -n "$PORT" ]]; then
      sed -i -e "s|Listen 80|Listen $PORT|g" /etc/httpd/conf/httpd.conf
      echo "Apache configuration updated to listen on port $PORT."
    else
      echo "PORT environment variable is not set. Using the default configuration."
    fi

    htpasswd -c -b /etc/httpd/auth.basic ${GANGLIA_USER} ${GANGLIA_USER_PASSWD}

    # Generate configuration files from templates
    envsubst < /ganglia_conf/gmetad.conf.template > /etc/ganglia/gmetad.conf
    envsubst < /ganglia_conf/gmond.conf.template > /etc/ganglia/gmond.conf
    envsubst < /ganglia_conf/ganglia.conf.template > /etc/httpd/conf.d/ganglia.conf
    echo "root:${ROOT_PASSWD}" | chpasswd
    groupadd -r ${GANGLIA_USER} && useradd -r -g ${GANGLIA_USER} ${GANGLIA_USER}
    echo "${GANGLIA_USER}:${GANGLIA_USER_PASSWD}" | chpasswd
    sed -i '34i Cmnd_Alias GANG_SERVICES = /usr/sbin/httpd, /usr/sbin/gmetad, /usr/sbin/gmond, /entrypoint.sh' /etc/sudoers
    sed -i '101i ${GANGLIA_USER} ALL=(ALL) NOPASSWD: GANG_SERVICES' /etc/sudoers
    # Start supervisord to manage services
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisord.conf
    touch /root/CONFIGURED
    su - ${GANGLIA_USER}

fi
   
