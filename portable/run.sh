#!/bin/bash

if ! docker images | awk '{print $1}' | grep  ganglia; then
  docker load < cdac_ganglia.img
else
  echo "Image 'ganglia' already exists."
fi

export $(cat ./.env) > /dev/null 2>&1;docker-compose up -d
