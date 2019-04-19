# Nginx Fpm 
This docker image contains nginx, php-fpm , drush and composer. You can find it in Docker hub here [https://hub.docker.com/r/appsvcorg/nginx-fpm/](https://hub.docker.com/r/appsvcorg/nginx-fpm/)
It can run on both [Azure Web App on Linux](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro) and your Docker engines's host.

# Docker Images for App Service Linux 
This repository contains docker images that are used for App Service Linux. Some images may be maintained by our team and some maintained by contirbutors.

## Components
This docker image currently contains the following components:

1. Nginx (1.15.8)   
2. PHP (7.3.2) 
3. MariaDB ( 10.1.38/if using Local Database )
4. Phpmyadmin ( 4.8.4/if using Local Database )

# How to Deploy to Azure 
1. Create a Web App for Containers 
2. Update App Setting ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true 
>If the ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` setting is false, the /home/ directory will not be shared across scale instances, and files that are written there will not be persisted across restarts.
3. Browse http://[website]/hostingstart.html 

# How to configure to use Local Database with web app 
1. Create a Web App for Containers 
2. Update App Setting ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true 
3. Add new App Settings 

Name | Default Value
---- | -------------
DATABASE_TYPE | local
DATABASE_USERNAME | some-string
DATABASE_PASSWORD | some-string
**Note: We create a database "azurelocaldb" when using local mysql . Hence use this name when setting up the app **

4. Browse http://[website]/phpmyadmin 

# How to turn on Xdebug to profile the app
1. By default Xdebug is turned off as turning it on impacts performance.
2. Connect by SSH.
3. Go to ```/usr/local/etc/php/conf.d```,  Update ```xdebug.ini``` as wish, don't modify the path of below line.
```zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so```
4. Save ```xdebug.ini```, 
5. Restart php-fpm by below cmd: 
```
# find gid of php-fpm
ps aux
# Kill master process of php-fpm
kill -INT <gid>
# start php-fpm again
php-fpm -D && chmod 777 /run/php/php-fpm.sock
```
5. Xdebug is turned on.

# How to update config files of nginx
1. Go to "/etc/nginx", update config files as your wish. 
5. Reload by below cmd: 
```
/usr/sbin/nginx -s reload
```

## Limitations
- Some unexpected issues may happen after you scale out your site to multiple instances, if you deploy a site on Azure with this docker image and use the MariaDB built in this docker image as the database.
- The phpMyAdmin built in this docker image is available only when you use the MariaDB built in this docker image as the database.
- Must include  App Setting ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true  since we need files to be persisted.

## Change Log
- **Version php7.3.2** 
  1. Upgrade version of alpine to 3.9.
  2. Upgrade version of php to 7.3.2.
  3. Upgrade version of nginx to 1.15.8.
  4. Upgrade version of mariadb to 10.1.38.  
- **Version php7.3.1** 
  1. Upgrade version of php to 7.3.1.
  2. Upgrade nginx version to 1.14.2.  
- **Version php7.2.13** 
  1. Upgrade version of php to 7.2.13.
  2. Upgrade phpmyadmin to 4.8.4.
  3. Keep watching php-fpm by supervisor.
  4. Log rotate isn't working well with AZURE, disable it if deploy to azure.
- **Version php7.2.12** 
  1. Upgrade version of alpine to 3.8.
  2. Upgrade version of php to 7.2.12.
  3. Upgrade version of phpmyadmin to 4.8.3.
  4. Add Log rotate.
  5. Add supervisor, keep watching nginx thread.
- **Version php7.2.11** 
  1. Upgrade version of php to 7.2.11.
- **Version 0.41** 
  1. Upgrade version of php to 7.2.9.
  4. Root directory isn't binded with /home.
- **Version 0.4** 
  1. Change base image to alpine:3.7, reduce size.
  2. Upgrade version of nginx to 1.14.0.
  3. Upgrade version of php to 7.2.7.
  4. Upgrade the conf of php-fpm, pass env parameters to php codes.
- **Version 0.3** 
  1. Add Xdebug.
  2. Upgrade version of nginx to 1.13.11.
  3. Upgrade version of phpmyadmin to 4.8.0.
- **Version 0.2** 
  1. Supports local MySQL.
  2. Create default database - azurelocaldb.(You need set DATABASE_TYPE to **"local"**)
  3. Considering security, please set database authentication info on **"App settings"** when enable **"local"** mode.   
     Note: the credentials below is also used by phpMyAdmin.
      -  DATABASE_USERNAME | <*your phpMyAdmin user*>
      -  DATABASE_PASSWORD | <*your phpMyAdmin password*>

# How to Contribute
If you have feedback please create an issue but **do not send Pull requests** to these images since any changes to the images needs to tested before it is pushed to production. 
