#!/bin/bash

setup_mariadb_data_dir(){
    test ! -d "$MARIADB_DATA_DIR" && echo "INFO: $MARIADB_DATA_DIR not found. creating ..." && mkdir -p "$MARIADB_DATA_DIR"

    # check if 'mysql' database exists
    if [ ! -d "$MARIADB_DATA_DIR/mysql" ]; then
	    echo "INFO: 'mysql' database doesn't exist under $MARIADB_DATA_DIR. So we think $MARIADB_DATA_DIR is empty."
	    echo "Copying all data files from the original folder /var/lib/mysql to $MARIADB_DATA_DIR ..."
	    cp -R /var/lib/mysql/. $MARIADB_DATA_DIR
    else
	    echo "INFO: 'mysql' database already exists under $MARIADB_DATA_DIR."
    fi

    rm -Rf /var/lib/mysql
    ln -s $MARIADB_DATA_DIR /var/lib/mysql
    chown -R mysql:mysql $MARIADB_DATA_DIR
    test ! -d /run/mysqld && echo "INFO: /run/mysqld not found. creating ..." && mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld    
}

start_mariadb(){
    if test ! -e /run/mysqld/mysqld.sock; then 
        touch /run/mysqld/mysqld.sock
    fi
    chmod 777 /run/mysqld/mysqld.sock
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    /usr/bin/mysqld --user=mysql &
    # make sure mysql service is started...
    port=`netstat -nlt|grep 3306|wc -l`
    process=`ps -ef |grep mysql|grep -v grep |wc -l`
    try_count=1

    while [ $try_count -le 10 ]
    do 
        if [ $port -eq 1 ] && [ $process -eq 1 ]; then 
            echo "INFO: MariaDB is running... "            
            break
        else            
            echo "INFO: Haven't found MariaDB Service this time, Wait 10s, try again..."
            sleep 10s
            let try_count+=1
            port=`netstat -nlt|grep 3306|wc -l`
            process=`ps -ef |grep mysql|grep -v grep |wc -l`    
        fi
    done

    # create default database 'azurelocaldb'
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS azurelocaldb; FLUSH PRIVILEGES;"
}

#unzip phpmyadmin
setup_phpmyadmin(){
    test ! -d "$PHPMYADMIN_HOME" && echo "INFO: $PHPMYADMIN_HOME not found. creating..." && mkdir -p "$PHPMYADMIN_HOME"
    cd $PHPMYADMIN_SOURCE
    tar -xf phpMyAdmin.tar.gz -C $PHPMYADMIN_HOME/ --strip-components=1    
    sed -i "/# Add locations of phpmyadmin here./r $PHPMYADMIN_SOURCE/phpmyadmin-locations.txt" /etc/nginx/nginx.conf    
    sed -i "/# Add locations of phpmyadmin here./r $PHPMYADMIN_SOURCE/phpmyadmin-vcl.txt" /etc/varnish/default.vcl    
    cp -R phpmyadmin-config.inc.php $PHPMYADMIN_HOME/config.inc.php    
	cd /
    rm -Rf $PHPMYADMIN_SOURCE
    if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then
        echo "INFO: NOT in Azure, chown for "$PHPMYADMIN_HOME  
        chown -R nginx:nginx $PHPMYADMIN_HOME
    fi
}

#Get drupal from Git
setup_drupal(){
    while test -d "$DRUPAL_PRJ"  
    do
        echo "INFO: $DRUPAL_PRJ is exist, clean it ..."
        # mv is faster than rm.    
        mv $DRUPAL_PRJ /home/bak/drupal_prj_bak$(date +%s)
    done
    test ! -d "$DRUPAL_PRJ" && echo "INFO: $DRUPAL_PRJ not found. creating..." && mkdir -p "$DRUPAL_PRJ"	
	cd $DRUPAL_PRJ
	GIT_REPO=${GIT_REPO:-https://github.com/azureappserviceoss/drupalcms-composer-azure}
	GIT_BRANCH=${GIT_BRANCH:-master}
	echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"
	echo "REPO: "$GIT_REPO
	echo "BRANCH: "$GIT_BRANCH
	echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"
    
	echo "INFO: Clone from "$GIT_REPO
    git clone $GIT_REPO $DRUPAL_PRJ	&& cd $DRUPAL_PRJ
	if [ "$GIT_BRANCH" != "master" ];then
		echo "INFO: Checkout to "$GIT_BRANCH
		git fetch origin
	    git branch --track $GIT_BRANCH origin/$GIT_BRANCH && git checkout $GIT_BRANCH
	fi

    if [ $DATABASE_USERNAME ]; then
        #cd $DRUPAL_PRJ/web/core/lib/Drupal/Core/Database/Installing
        echo "INFO: Setting of DATABASE ..."
        mkdir -p /home/bak
        mv $DRUPAL_PRJ/web/core/lib/Drupal/Core/Database/Install/Tasks.php /home/bak/Tasks$(date +%s).php        
        cp $DRUPAL_SOURCE/drupal-database-install-tasks.php $DRUPAL_PRJ/web/core/lib/Drupal/Core/Database/Install/Tasks.php 
        # cd $DRUPAL_PRJ/
    fi

    # restore old site to drupal project
    if [ -d /home/bak/drupal_site ]; then 
        echo "INFO: Restore old version site ..."
        while test -d "$DRUPAL_PRJ/web"  
        do
            # mv is faster than rm.
            mv $DRUPAL_PRJ/web /home/bak/drupal_prj_web_bak$(date +%s)            
        done
        mv /home/bak/drupal_site $DRUPAL_PRJ/web/
    fi
        
    chmod a+w "$DRUPAL_PRJ/web/sites/default" 
    if [ -e "$DRUPAL_PRJ/web/sites/default/settings.php" ]; then 
        #Test this time, if application settings are set to a personal git, myabe drupal has already installed in repo.
        echo "INFO: Settings.php is exist..."    
    else
        echo "INFO: Settings.php isn't exist..."    
        mkdir -p "$DRUPAL_PRJ/web/sites/default/files"
        cp "$DRUPAL_PRJ/web/sites/default/default.settings.php" "$DRUPAL_PRJ/web/sites/default/settings.php"
    fi
    chmod a+w "$DRUPAL_PRJ/web/sites/default/files"
    chmod a+w "$DRUPAL_PRJ/web/sites/default/settings.php"
    while test -d "$DRUPAL_HOME"  
    do
        echo "INFO: $DRUPAL_HOME is exist, clean it ..."        
        chmod 777 -R $DRUPAL_HOME 
        rm -Rf $DRUPAL_HOME
    done
    ln -s $DRUPAL_PRJ/web  $DRUPAL_HOME           	
}

if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then 
    echo "INFO: NOT in Azure, chown for "$DRUPAL_HOME 
    chown -R nginx:nginx $DRUPAL_HOME
fi

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

DATABASE_TYPE=$(echo ${DATABASE_TYPE}|tr '[A-Z]' '[a-z]')
if [ "${DATABASE_TYPE}" == "local" ]; then  
    echo "Starting MariaDB and PHPMYADMIN..."
    echo 'mysql.default_socket = /run/mysqld/mysqld.sock' >> $PHP_CONF_FILE     
    echo 'mysqli.default_socket = /run/mysqld/mysqld.sock' >> $PHP_CONF_FILE     
    #setup MariaDB
    echo "INFO: loading local MariaDB and phpMyAdmin ..."
    echo "Setting up MariaDB data dir ..."
    setup_mariadb_data_dir
    echo "Setting up MariaDB log dir ..."
    test ! -d "$MARIADB_LOG_DIR" && echo "INFO: $MARIADB_LOG_DIR not found. creating ..." && mkdir -p "$MARIADB_LOG_DIR"
    chown -R mysql:mysql $MARIADB_LOG_DIR
    echo "Starting local MariaDB ..."
    start_mariadb

    echo "Granting user for phpMyAdmin ..."
    # Set default value of username/password if they are't exist/null.
    DATABASE_USERNAME=${DATABASE_USERNAME:-phpmyadmin}
    DATABASE_PASSWORD=${DATABASE_PASSWORD:-MS173m_QN}
    DATABASE_HOST=${DATABASE_HOST:-127.0.0.1}
    DATABASE_NAME=${DATABASE_NAME:-azurelocaldb}
    echo "phpmyadmin username: "$DATABASE_USERNAME    
    echo "phpmyadmin password: "$DATABASE_PASSWORD 
    export DATABASE_HOST
    export DATABASE_NAME
    export DATABASE_USERNAME
    export DATABASE_PASSWORD   
    mysql -u root -e "GRANT ALL ON *.* TO \`$DATABASE_USERNAME\`@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
     
    echo "Installing phpMyAdmin ..."
    setup_phpmyadmin
fi

# setup Drupal
if [ -e "$DRUPAL_HOME/sites/default/settings.php" ]; then
# Site is exist.
    if [ -d "$DRUPAL_PRJ" ]; then
    # site is exist and is built by composer build, no need to git pull again.
        echo "INFO: $DRUPAL_PRJ is exist..."        
        echo "INFO: Site is Ready..."
    else
    # site is exist and it's not built by composer build, backup it at first.
        echo "INFO: Old Version Site is exist, Backup Site..."        
        if [ -d /home/bak/drupal_site ]; then
            mv /home/bak/drupal_site /home/bak/drupal_site$(date +%s)
        else            
            mkdir -p /home/bak
        fi
        mv $DRUPAL_HOME /home/bak/drupal_site
        echo "Installing Drupal ..."    
        setup_drupal  
    fi    
else
# drupal isn't installed, fresh start
    echo "Installing Drupal ..."    
    setup_drupal   
fi

if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then
    echo "INFO: NOT in Azure, chown for "$DRUPAL_PRJ  
    chown -R nginx:nginx $DRUPAL_PRJ 
fi

if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then
    echo "NOT in AZURE, Start crond, log rotate..."
    crond
fi   

test ! -d "$SUPERVISOR_LOG_DIR" && echo "INFO: $SUPERVISOR_LOG_DIR not found. creating ..." && mkdir -p "$SUPERVISOR_LOG_DIR"
test ! -d "$VARNISH_LOG_DIR" && echo "INFO: Log folder for varnish found. creating..." && mkdir -p "$VARNISH_LOG_DIR"
test ! -d "$NGINX_LOG_DIR" && echo "INFO: Log folder for nginx/php not found. creating..." && mkdir -p "$NGINX_LOG_DIR"
test ! -e /home/50x.html && echo "INFO: 50x file not found. createing..." && cp /usr/share/nginx/html/50x.html /home/50x.html
