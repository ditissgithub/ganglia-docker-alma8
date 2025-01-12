#!/bin/bash
export $(cat /drbd/cont_env/.env) > /dev/null 2>&1;docker-compose up -d
