#
# Docker image for running https://github.com/phacility/phabricator
#

FROM    debian:jessie
MAINTAINER  Yvonnick Esnault <yvonnick@esnau.lt>

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# TODO: review this dependency list
RUN     apt-get update && apt-get install -y \
	    git \
            apache2 \
            curl \
            libapache2-mod-php5 \
            libmysqlclient18 \
            mercurial \
            mysql-client \
            php-apc \
            php5 \
            php5-apcu \
            php5-cli \
            php5-curl \
            php5-gd \
            php5-json \
            php5-ldap \
            php5-mysql \
            python-pygments \
            sendmail \
            subversion \
            tar \
            sudo \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# For some reason phabricator doesn't have tagged releases. To support
# repeatable builds use the latest SHA
ADD     download.sh /opt/download.sh
WORKDIR /opt
RUN     bash download.sh phabricator 79f2e81f38
RUN     bash download.sh arcanist    c304c4e045
RUN     bash download.sh libphutil   55f554b618

# Setup apache
RUN     a2enmod rewrite
ADD     phabricator.conf /etc/apache2/sites-available/phabricator.conf
RUN     ln -s /etc/apache2/sites-available/phabricator.conf \
            /etc/apache2/sites-enabled/phabricator.conf && \
        rm -f /etc/apache2/sites-enabled/000-default.conf
ADD     ports.conf /etc/apache2/ports.conf

# Setup phabricator
RUN     mkdir -p /opt/phabricator/conf/local /var/repo
ADD     local.json /tmp/local.json
RUN     sed -e 's/post_max_size = 8M/post_max_size = 32M/' \
          -e 's/upload_max_filesize = 2M/upload_max_filesize = 32M/' \
          -i /etc/php5/apache2/php.ini
RUN     ln -s /usr/lib/git-core/git-http-backend /opt/phabricator/support/bin
RUN     echo "www-data ALL=(ALL) SETENV: NOPASSWD: /opt/phabricator/support/bin/git-http-backend" >> /etc/sudoers

# User
# Unfortunately apache needs the root right,
# so don't assign the USER to use the root by default in openshift
#
#ENV     HOME=/opt
#RUN     mkdir -p ${HOME} && \
#          useradd -u 1001 -r -g 0 -d ${HOME} LOGIN && \
#          chown -R 1001:0 ${HOME} && \
#          chown -R 1001:0 /var/log/apache2/
#WORKDIR ${HOME}
#USER    1001

EXPOSE  8080

ADD     entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD     ["start-server"]
