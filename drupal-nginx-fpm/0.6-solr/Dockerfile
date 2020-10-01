FROM appsvcorg/drupal-nginx-fpm:0.6
LABEL maintainer ="Azure App Service Container Images <appsvc-images@microsoft.com>"
# ========
# ENV vars
# ========
#
ENV DOCKER_BUILD_HOME "/dockerbuild"
# drupal 
ENV DRUPAL_HOME "/home/site/wwwroot"
ENV DRUPAL_PRJ "/home/drupal_prj"
# mariadb
ENV MARIADB_DATA_DIR "/home/data/mysql"
ENV MARIADB_LOG_DIR "/home/LogFiles/mysql"
# phpmyadmin
ENV PHPMYADMIN_SOURCE "/usr/src/phpmyadmin"
ENV PHPMYADMIN_HOME "/home/phpmyadmin"
# drupal
ENV DRUPAL_SOURCE "/usr/src/drupal"
#nginx
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
#varnish
ENV VARNISH_LOG_DIR "/home/LogFiles/varnish"
#php
ENV PHP_CONF_FILE "/usr/local/etc/php/php.ini"

RUN set -ex \
  && apk update \ 
  && apk add bash openjdk8 \
  && apk upgrade \
  && rm -rf /var/cache/apk/* \
  && rm -rf /etc/nginx/conf.d/default.conf 

# install drupal and mariadb
WORKDIR $DRUPAL_HOME

ENV DATABASE_TYPE local
COPY install_drupal.sh /etc
RUN chmod u+x /etc/install_drupal.sh \
  && /etc/install_drupal.sh \
  && chown -R nginx:nginx $DRUPAL_PRJ 

# Apache Solr
RUN apk add apache-ant
COPY solr-8.1.1-src.tgz /usr/src/solr-8.1.1-src.tgz

RUN tar -xvf /usr/src/solr-8.1.1-src.tgz -C /usr/src
RUN cd /usr/src/solr-8.1.1 \
  && ant ivy-bootstrap \
  && ant compile \
  && cd solr \
  && ant server \
  && chmod u+x bin/solr \
  && bin/solr start -force
ENV PATH "/usr/src/solr-8.1.1/solr/bin/:${PATH}"

# search_api_solr
RUN cd "${DRUPAL_PRJ}" \
  && composer require drupal/search_api_solr \ 
  && solr start -force \
  && solr create -c firstcollection -n data_driven_schema_configs -force \
  && cd /usr/src/solr-8.1.1/solr/server/solr/firstcollection \
  && mv conf conf.old \
  && cp -R "${DRUPAL_HOME}"/modules/contrib/search_api_solr/solr-conf-templates/7.x conf \
  && sed -i '19a <searchComponent name="spellcheck" class="solr.SpellCheckComponent" />'  conf/solrconfig.xml \
  && adduser -D solr \
  && chown -R solr:solr conf \
  && chmod -R 775 conf \
  && solr stop -force -all \
#  && sleep 180 \
  && sleep 5 \ 
  && solr start -force 
# =====
# final
# =====


COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80 2222
ENTRYPOINT ["entrypoint.sh"]
