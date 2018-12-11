FROM php:7.2.12-fpm-alpine3.8
MAINTAINER Azure App Service Container Images <appsvc-images@microsoft.com>
# ========
# ENV vars
# ========
# ssh
ENV SSH_PASSWD "root:Docker!"
#nginx
ENV NGINX_VERSION 1.14.0
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
#php
ENV PHP_HOME "/usr/local/etc/php"
ENV PHP_CONF_DIR $PHP_HOME
ENV PHP_CONF_FILE $PHP_CONF_DIR"/php.ini"
# mariadb
ENV MARIADB_DATA_DIR "/home/data/mysql"
ENV MARIADB_LOG_DIR "/home/LogFiles/mysql"
ENV MARIADB_VER 10.1.26
ENV JUDY_VER 1.0.5
# phpmyadmin
ENV PHPMYADMIN_SOURCE "/usr/src/phpmyadmin"
ENV PHPMYADMIN_HOME "/home/phpmyadmin"
#Web Site Home
ENV HOME_SITE "/home/site/wwwroot"
# supervisor
ENV SUPERVISOR_LOG_DIR "/home/LogFiles/supervisor"
#
# --------
# ~. tools
# --------
RUN set -ex \
    && apk update \
    && apk add --no-cache openssl git net-tools tcpdump tcptraceroute vim curl wget bash\
	&& cd /usr/bin \
	&& wget http://www.vdberg.org/~richard/tcpping \
	&& chmod 777 tcpping \
# ========
# install the PHP extensions we need and xdebug
# ======== 
    && apk add --no-cache                  \
            --virtual .build-dependencies   \
                $PHPIZE_DEPS                \
                zlib-dev                    \
                cyrus-sasl-dev              \
                git                         \
                autoconf                    \
                g++                         \
                libtool                     \
                make                        \
                pcre-dev                    \    
            tini                            \
            libintl                         \
            icu                             \
            icu-dev                         \
            libxml2-dev                     \
            postgresql-dev                  \
            freetype-dev                    \
            libjpeg-turbo-dev               \
            libpng-dev                      \
            gmp                             \
            gmp-dev                         \
            libmemcached-dev                \
            imagemagick-dev                 \
            libssh2                         \
            libssh2-dev                     \
            libxslt-dev                     \    
    && docker-php-source extract \
    && pecl install xdebug-beta apcu \
    && docker-php-ext-install -j "$(nproc)" \
	    mysqli \
		opcache \
		pdo_mysql \
		pdo_pgsql \
	&& docker-php-ext-enable apcu \
    && docker-php-source delete \
    && runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --virtual .drupal-phpexts-rundeps $runDeps \
	&& apk del .build-dependencies \	
	&& docker-php-source delete \
	&& mkdir -p /usr/local/php/tmp \
	&& chmod 777 /usr/local/php/tmp \
# ------
# ssh
# ------
    && apk add --no-cache openssh-server \
    && echo "$SSH_PASSWD" | chpasswd \
#---------------
# openrc service
#---------------
   && apk add --no-cache openrc \
   && sed -i 's/"cgroup_add_service/" # cgroup_add_service/g' /lib/rc/sh/openrc-run.sh
# ----------
# Nginx
# ----------   
RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
	" \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
	&& curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& rm nginx.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	&& apk add --no-cache tzdata \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	# change default root path to $HOME_SITE
	&& mkdir -p /etc/nginx/conf.d \
    && mkdir -p ${HOME_SITE} \
    && chown -R nginx:nginx $HOME_SITE \
    && echo "<?php phpinfo();" > $HOME_SITE/index.php \
# ------
# mariadb
# ------
#RUN \
    #export CPU=`cat /proc/cpuinfo | grep -c processor` \
    # Add testing repo
    && echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    # Install packages
    && apk add --no-cache \
        # Install utils
        pwgen openssl ca-certificates \
        # Installing needed libs
        libstdc++ libaio gnutls ncurses-libs libcurl libxml2 boost proj4 geos \
        # Install MariaDB build deps
        alpine-sdk cmake ncurses-dev gnutls-dev curl-dev libxml2-dev libaio-dev linux-headers bison boost-dev \
    # Update CA certs
    && update-ca-certificates \
    # Add group and user for mysql
    && addgroup -S -g 500 mysql \
    && adduser -S -D -H -u 500 -G mysql -g "MySQL" mysql \
    # Unpack mariadb    
	# http://ftp.hosteurope.de/mirror/archive.mariadb.org//mariadb-10.1.26/source/mariadb-10.1.26.tar.gz
	&& mkdir -p /opt/src \
	&& wget -O /opt/src/mdb.tar.gz http://ftp.hosteurope.de/mirror/archive.mariadb.org//mariadb-$MARIADB_VER/source/mariadb-$MARIADB_VER.tar.gz \
    && mkdir -p /etc/mysql \
    && cd /opt/src && tar -xf mdb.tar.gz && rm mdb.tar.gz \
    # Download and unpack Judy (needed for OQGraph)
    && wget -O /opt/src/judy.tar.gz http://downloads.sourceforge.net/project/judy/judy/Judy-${JUDY_VER}/Judy-${JUDY_VER}.tar.gz \
    && cd /opt/src && tar -xf judy.tar.gz && rm judy.tar.gz \
    # Build Judy
    && cd /opt/src/judy-${JUDY_VER} \
    && CFLAGS="-O2 -s" CXXFLAGS="-O2 -s" ./configure \
    && make \
    && make install \
    # Build maridb
    && mkdir -p /tmp/_ \
    && cd /opt/src/mariadb-${MARIADB_VER} \
    && cmake . \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCOMMON_C_FLAGS="-O3 -s -fno-omit-frame-pointer -pipe" \
        -DCOMMON_CXX_FLAGS="-O3 -s -fno-omit-frame-pointer -pipe" \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DSYSCONFDIR=/etc/mysql \
        -DMYSQL_DATADIR=/var/lib/mysql \
        -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock \
        -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DENABLED_LOCAL_INFILE=ON \
        -DINSTALL_INFODIR=share/mysql/docs \
        -DINSTALL_MANDIR=/tmp/_/share/man \
        -DINSTALL_PLUGINDIR=lib/mysql/plugin \
        -DINSTALL_SCRIPTDIR=bin \
        # -DINSTALL_INCLUDEDIR=/tmp/_/include/mysql \
        -DINSTALL_DOCREADMEDIR=/tmp/_/share/mysql \
        -DINSTALL_SUPPORTFILESDIR=share/mysql \
        -DINSTALL_MYSQLSHAREDIR=share/mysql \
        -DINSTALL_DOCDIR=/tmp/_/share/mysql/docs \
        -DINSTALL_SHAREDIR=share/mysql \
        -DWITH_READLINE=ON \
        -DWITH_ZLIB=system \
        -DWITH_SSL=system \
        -DWITH_LIBWRAP=OFF \
        -DWITH_JEMALLOC=no \
        -DWITH_EXTRA_CHARSETS=complex \
        -DPLUGIN_ARCHIVE=STATIC \
        -DPLUGIN_BLACKHOLE=DYNAMIC \
        -DPLUGIN_INNOBASE=STATIC \
        -DPLUGIN_PARTITION=AUTO \
        -DPLUGIN_CONNECT=NO \
        -DPLUGIN_TOKUDB=NO \
        -DPLUGIN_FEEDBACK=NO \
        -DPLUGIN_OQGRAPH=YES \
        -DPLUGIN_FEDERATED=NO \
        -DPLUGIN_FEDERATEDX=NO \
        -DWITHOUT_FEDERATED_STORAGE_ENGINE=1 \
        -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
        -DWITHOUT_PBXT_STORAGE_ENGINE=1 \
        -DWITHOUT_ROCKSDB_STORAGE_ENGINE=1 \
        -DWITH_EMBEDDED_SERVER=OFF \
        -DWITH_UNIT_TESTS=OFF \
        -DENABLED_PROFILING=OFF \
        -DENABLE_DEBUG_SYNC=OFF \
    #&& make -j${CPU} \
	&& make -j "$(nproc)" \
    # Install
    #&& make -j${CPU} install \
	&& make -j "$(nproc)" install \
    # Copy default config, and remove deprecates and not working things
    && cp /usr/share/mysql/my-large.cnf /etc/mysql/my.cnf \
    && echo "!includedir /etc/mysql/conf.d/" >>/etc/mysql/my.cnf \
    && sed -i '/# Try number of CPU/d' /etc/mysql/my.cnf \
    && sed -i '/thread_concurrency = 8/d' /etc/mysql/my.cnf \
    && sed -i '/innodb_additional_mem_pool_size/d' /etc/mysql/my.cnf \
    && sed -i 's/log-bin=/#log-bin=/' /etc/mysql/my.cnf \
    && sed -i 's/binlog_format=/#binlog_format=/' /etc/mysql/my.cnf \
    && sed -i 's/#innodb_/innodb_/' /etc/mysql/my.cnf \
    # Clean everything
    && rm -rf /opt/src \
    && rm -rf /tmp/_ \
    && rm -rf /usr/sql-bench \
    && rm -rf /usr/mysql-test \
    && rm -rf /usr/data \
    && rm -rf /usr/lib/python2.7 \
    && rm -rf /usr/bin/mysql_client_test \
    && rm -rf /usr/bin/mysqltest \
    # Remove packages
    && apk del \
        ca-certificates \
        # Remove no more necessary build dependencies
        alpine-sdk cmake ncurses-dev gnutls-dev curl-dev libxml2-dev libaio-dev linux-headers bison boost-dev \
    # Create needed directories
    && mkdir -p /var/lib/mysql \
    && mkdir -p /run/mysqld \
    && mkdir /etc/mysql/conf.d \
    && mkdir -p /opt/mariadb/pre-init.d \
    && mkdir -p /opt/mariadb/post-init.d \
    && mkdir -p /opt/mariadb/pre-exec.d \
    # Set permissions
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld\
    && chmod -R 755 /opt/mariadb \
# -------------
# log rotate & supervisor
# -------------
	&& apk update \
	&& apk add logrotate supervisor \	
	# rotate log files once/5 mins, triaged by crond.
	&& echo "*/5     *       *       *       *       /usr/sbin/logrotate /etc/logrotate.conf" >> /etc/crontabs/root \
# -------------
# phpmyadmin
# -------------
    && mkdir -p $PHPMYADMIN_SOURCE \
# ----------
# ~. upgrade/clean up
# ----------
	&& apk upgrade \
	&& rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* 
# =========
# Configure
# =========
RUN set -ex\    		
	##
	&& rm -rf /var/log/mysql \
	&& ln -s $MARIADB_LOG_DIR /var/log/mysql \
	##
	&& rm -rf /var/log/nginx \
	&& ln -s $NGINX_LOG_DIR /var/log/nginx \
	##
	&& rm -rf /var/log/supervisor \
	&& ln -s $SUPERVISOR_LOG_DIR /var/log/supervisor 
# ssh
COPY sshd_config /etc/ssh/ 
# php
COPY php.ini /usr/local/etc/php/php.ini
COPY opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY www.conf /usr/local/etc/php/conf.d/www.conf
COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
# nginx
COPY spec-settings.conf /etc/nginx/conf.d/spec-settings.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
# mariadb
COPY mariadb.cnf /etc/mysql/my.cnf
# phpmyadmin
COPY phpMyAdmin.tar.gz $PHPMYADMIN_SOURCE/phpMyAdmin.tar.gz
COPY phpmyadmin-config.inc.php $PHPMYADMIN_SOURCE/
COPY phpmyadmin-default.conf $PHPMYADMIN_SOURCE/phpmyadmin-default.conf
# log rotater
COPY logrotate.conf /etc/logrotate.conf
RUN chmod 444 /etc/logrotate.conf
COPY log-rotate-nginx /etc/logrotate.d/nginx
RUN chmod 444 /etc/logrotate.d/nginx
COPY log-rotate-php /etc/logrotate.d/php
RUN chmod 444 /etc/logrotate.d/php
COPY log-rotate-supervisord /etc/logrotate.d/supervisord
RUN chmod 444 /etc/logrotate.d/supervisord
# supervisor
COPY supervisord.conf /etc/
COPY super_nginx.sh /usr/local/bin
RUN chmod +x /usr/local/bin/super_nginx.sh
#
# =====
# final
# =====
COPY init_container.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_container.sh
EXPOSE 2222 80
ENTRYPOINT ["init_container.sh"]
