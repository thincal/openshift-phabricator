#!/bin/bash

# mysql as a linked docker
docker rm -f phabricator-database
docker run --name phabricator-database -d ceyes/docker-phabricator-mysql
docker rm -f phabricator-server
docker run --name phabricator-server -d -p 8081:8080 --link phabricator-database:database ceyes/docker-phabricator
