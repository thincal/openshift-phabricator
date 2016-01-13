#!/bin/sh

if [ ! -f /opt/phabricator/conf/local/local.json ]; then
  echo "local.json is not present, then create it!"
  cp /tmp/local.json /opt/phabricator/conf/local/local.json

  # Patching the settings file.
  sed -e "s/{{MYSQL_HOST}}/${MYSQL_HOST}/g" \
      -e "s/{{MYSQL_PORT}}/${MYSQL_PORT}/g" \
      -e "s/{{MYSQL_USER}}/${MYSQL_USER}/g" \
      -e "s/{{MYSQL_PASS}}/${MYSQL_PASS}/g" \
      -i /opt/phabricator/conf/local/local.json
else
  echo "local.json is already present..."
fi

echo "local.json content:"
cat /opt/phabricator/conf/local/local.json

if [ "${1}" = "start-server" ]; then
  echo "start: bootup phabricator server now..."
  exec bash -c "/opt/phabricator/bin/storage upgrade --force; /opt/phabricator/bin/phd start; source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND"
else
  echo "start: other cmd: $@"
  exec $@
fi
