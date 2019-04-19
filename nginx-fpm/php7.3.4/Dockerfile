FROM php:7.3.2-fpm-alpine3.9
LABEL maintainer Azure App Service Container Images <appsvc-images@microsoft.com>
# ========
# ENV vars
# ========
# ssh
ENV SSH_PASSWD "root:Docker!"
ENV SSH_PORT 2222
#nginx
ENV NGINX_VERSION 1.15.8
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
#php
ENV PHP_HOME "/usr/local/etc/php"
ENV PHP_CONF_DIR $PHP_HOME
ENV PHP_CONF_FILE $PHP_CONF_DIR"/php.ini"
# mariadb
ENV MARIADB_DATA_DIR "/home/data/mysql"
ENV MARIADB_LOG_DIR "/home/LogFiles/mysql"
ENV MARIADB_VER 10.1.38
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
   && sed -i 's/"cgroup_add_service/" # cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
# ----------
# Nginx
# ----------
# RUN set -ex\ 
	&& GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
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
		gnupg1 \
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
	#
	# change default root path to $HOME_SITE
	&& mkdir -p /etc/nginx/conf.d \
    && mkdir -p ${HOME_SITE} \
    && chown -R www-data:www-data $HOME_SITE \
    && echo "<?php phpinfo();" > $HOME_SITE/index.php \
# ------
# mariadb
# ------
# RUN set -ex\ 
    #export CPU=`cat /proc/cpuinfo | grep -c processor` \
    # Add testing repo
    && echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    # Install packages
    #&& apk add --no-cache \
        # Install utils
    #    openssl ca-certificates \
    &&	apk add --update --no-cache -t .mariadb-run-deps \
        libaio \
        libstdc++ \
        make \
        pwgen \
        sudo \
        tzdata \
		# MariaDB 10.1 does not support OpenSSL 1.1.
        $(test "${MARIADB_VER:0:4}" = "10.1" && echo 'libressl-dev' || echo 'openssl-dev') \
    \
    && apk add --update --no-cache -t .mariadb-build-deps \
        attr \
        autoconf \
        bison \
        build-base \
        cmake \
        coreutils \
        gnupg \
        libaio-dev \        
        linux-headers \
        ncurses-dev \
        patch \
        readline-dev \
        zlib-dev \
    \
    # Update CA certs
    && update-ca-certificates \
    # Add group and user for mysql
    && addgroup -S -g 500 mysql \
    && adduser -S -D -H -u 500 -G mysql -g "MySQL" mysql \
# RUN set -ex\ 
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
    		# -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    		# -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    		# -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    		# -DWITH_PARTITION_STORAGE_ENGINE=1 \
    		-DPLUGIN_TOKUDB=NO \
			-DWITHOUT_FEDERATED_STORAGE_ENGINE=1 \
    		-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \    		
    		-DWITHOUT_PBXT_STORAGE_ENGINE=1 \
			-DWITH_EMBEDDED_SERVER=OFF \
    && make -j "$(nproc)" \
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
    #&& apk del \
    #    ca-certificates \
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
	\
    # Clean up.
    && apk del --purge .mariadb-build-deps \
#
# -------------
# log rotate & supervisor
# -------------
	&& apk update \
	&& apk add logrotate supervisor \	
	# check log files once every minute, triaged by crond.
	&& echo "*       *       *       *       *       sh /usr/local/bin/triage-rotate.sh" >> /etc/crontabs/root \
# -------------
# phpmyadmin
# -------------
    && mkdir -p $PHPMYADMIN_SOURCE \
# ----------
# ~. upgrade/clean up
# ----------
	&& apk upgrade \
	&& rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
# =========
# Configure
# =========
# RUN set -ex\    		
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
COPY php_conf/. /usr/local/etc/php/conf.d/
COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
# nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx_conf/. /etc/nginx/conf.d/
# mariadb
COPY mariadb.cnf /etc/mysql/my.cnf
# COPY my.cnf /etc/my.cnf
# phpmyadmin
COPY phpmyadmin_src/. $PHPMYADMIN_SOURCE/
# log rotater
COPY logrotate.conf /etc/logrotate.conf
RUN chmod 444 /etc/logrotate.conf
COPY logrotate.d/. /etc/logrotate.d/
RUN chmod -R 444 /etc/logrotate.d
# supervisor
COPY supervisord.conf /etc/
#
# =====
# final
# =====
COPY local_bin/. /usr/local/bin/
RUN chmod -R +x /usr/local/bin
EXPOSE 2222 80
ENTRYPOINT ["init_container.sh"]
