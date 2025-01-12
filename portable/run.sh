#!/bin/bash
export $(cat ./.env) > /dev/null 2>&1;docker-compose up -d
