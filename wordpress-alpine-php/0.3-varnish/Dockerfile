#
# Dockerfile for WordPress
#
FROM appsvcorg/alpine-php-mysql:0.2 
MAINTAINER Azure App Service Container Images <appsvc-images@microsoft.com>

# ========
# ENV vars
# ========

# wordpress
ENV WORDPRESS_SOURCE "/usr/src/wordpress"
ENV WORDPRESS_HOME "/home/site/wwwroot"

#
ENV DOCKER_BUILD_HOME "/dockerbuild"

# varnish
ENV VARNISH_BACKEND_ADDRESS 127.0.0.1
ENV VARNISH_BACKEND_PORT 80
ENV VARNISH_CACHE_SIZE 250M
ENV VARNISH_PORT 80

# ====================
# Download and Install
# ~. tools
# 1. redis
# 2. wordpress
# ====================

WORKDIR $DOCKER_BUILD_HOME
RUN set -ex \
    # --------
	# ~. tools
	# --------
    && apk add --update git \
	# --------
	# 1. redis
	# --------
    && apk add --update redis \
	# ------------	
	# 2. wordpress
	# ------------
	&& mkdir -p $WORDPRESS_SOURCE \
	# ------------
	# 3. varnish
	# ------------
	&& apk add --update varnish \
	# ------------
	# cp in final
	# ----------
	# ~. clean up
	# ----------
	&& rm -rf /var/cache/apk/* 

# =========
# Configure
# =========
# httpd confs
COPY httpd.conf $HTTPD_CONF_DIR/
COPY httpd-wordpress.conf $HTTPD_CONF_DIR/

# varnish start script
COPY start-varnish.sh /usr/sbin
RUN chmod a+x /usr/sbin/start-varnish.sh

RUN set -ex \
	##
	&& ln -s $WORDPRESS_HOME /var/www/wordpress \
    ##
    && test -e /usr/local/bin/entrypoint.sh && mv /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.bak
	
# =====
# final
# =====
COPY wp-config.php $WORDPRESS_SOURCE/

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
