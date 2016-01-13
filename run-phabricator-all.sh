#!/bin/bash

# mysql as an external docker
docker rm -f phabricator-database
docker run --name phabricator-database -d -p 3306:3306 ceyes/docker-phabricator-mysql
docker rm -f phabricator-server
docker run --name phabricator-server -d -p 8081:8080 \
  -e MYSQL_HOST=master1.ceyes.os -e MYSQL_PORT=3306 -e MYSQL_USER=admin -e MYSQL_PASS=admin \
  registry.ceyes.os:5000/ceyes-ci/phabricator:latest
