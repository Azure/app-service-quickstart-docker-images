FROM appsvcorg/nginx-fpm:0.3
MAINTAINER Azure App Service Container Images <appsvc-images@microsoft.com>

# ========
# ENV vars
# ========
#
ENV DOCKER_BUILD_HOME "/dockerbuild"
# drupal 
ENV DRUPAL_HOME "/home/site/wwwroot"
# mariadb
ENV MARIADB_DATA_DIR "/home/data/mysql"
ENV MARIADB_LOG_DIR "/home/LogFiles/mysql"
# phpmyadmin
ENV PHPMYADMIN_SOURCE "/usr/src/phpmyadmin"
ENV PHPMYADMIN_HOME "/home/phpmyadmin"
#nginx
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
#php
ENV PHP_HOME "/etc/php/7.0"
ENV PHP_CONF_DIR $PHP_HOME"/cli"
ENV PHP_CONF_FILE $PHP_CONF_DIR"/php.ini" 

# ====================
# Download and Install
# ~. essentials
# 1. Drupal
# ====================

RUN mkdir -p $DOCKER_BUILD_HOME
WORKDIR $DOCKER_BUILD_HOME
# --------
# ~. tools
# --------
RUN set -ex \
    && apt-get update \
    && apt-get install -y -V --no-install-recommends git

# -------------
# 1. Drupal
# -------------
# Install by Git

# ----------
	# ~. clean up
	# ----------
RUN set -ex \
	&& apt-get autoremove -y

# =========
# Configure
# =========
WORKDIR $DRUPAL_HOME
RUN rm -rf $DOCKER_BUILD_HOME

# =====
# final
# =====
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
