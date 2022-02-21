#!/bin/bash

read -d '' dockerCompose << EOF
version: '3.0'
services:
  sonar:
    container_name: sonar
    build:
      dockerfile: Dockerfile.sonar
    ports:
      - 9000:9000
      - 9002:9002
    network_mode: host
    logging:
      driver: none
    healthcheck:
      test: curl -s "http://localhost:9000/api/system/status" | grep '"status":"UP"' || exit 1
      interval: 5s
      timeout: 10s
      retries: 10
  sonar-scanner:
    container_name: sonar-scanner
    build: 
      dockerfile: Dockerfile.sonar-scanner
    network_mode: host
    environment:
      - PROJECT_KEY=example
      - BRANCH1=master
      - BRANCH2=release/0.0.1
    depends_on:
      sonar:
        condition: service_healthy
EOF

docker-compose  -f - up --build <<<"$dockerCompose"