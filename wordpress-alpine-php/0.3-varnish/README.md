# Wordpress-alpine-php Docker Image 
This is a WordPress Docker image which can run on both [Azure Web App on Linux](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro) and your Docker engines's host.

## Components
This docker image currently contains the following components:

1. WordPress   
2. Alpine (3.6)
3. PHP (7.2.4)
4. Apache/Httpd (2.4.33)
5. MariaDB ( 10.1.26/if using Local Database )
6. Phpmyadmin ( 4.8.0/if using Local Database )
7. Varnish (4.1.9) (Requires additional steps, view below)

## How to configure to use Azure Database for MySQL with web app 
1. Create a Web App for Containers
2. Browse your site 
3. Complete WordPress install and Enter the Credentials for Azure database for MySQL 

## How to configure GIT Repo and Branch
1. Create a Web App for Containers 
2. Add new App Settings 

Name | Default Value
---- | -------------
GIT_REPO | https://github.com/azureappserviceoss/wordpress-azure
GIT_BRANCH | linux_appservice

4. Browse your site

>Note: GIT directory: /home/site/wwwroot.
>
>Note: When you deploy it first time, Sometimes need to check wp-config.php. RM it and re-config DB information is necessary.
>
>Note: Before restart web app, need to store your changes by "git push", it will be pulled again after restart.
>

## How to configure to use Local Database with web app 
1. Create a Web App for Containers 
2. Update App Setting ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true (If you like to keep you DB after restart.)
3. Add new App Settings 

Name | Default Value
---- | -------------
DATABASE_TYPE | local
DATABASE_USERNAME | wordpress
DATABASE_PASSWORD | some-string
>Note: We create a database "azurelocaldb" when using local mysql . Hence use this name when setting up the app

4. Browse your site 
5. Complete WordPress install

>Note: Do not use the app setting DATABASE_TYPE=local if using Azure database for MySQL

## How to use Varnish in-memory caching
1. Disable ARR Affinity in Application Settings. Requests containing cookies will not be cached.
2. The default in-memory cache size is 250M. If you need to change the value, add an Application Setting called VARNISH_CACHE_SIZE with a supported value as per the documentation: https://varnish-cache.org/docs/trunk/users-guide/storage-backends.html#malloc;
3. The Cache-Control headers will be respected, so use this header in order to control TTL and enable/disable cache more granularly. Plugins like Cache-Control make this easier: https://wordpress.org/plugins/cache-control/ 

Currently, only in-memory caching is available for this image.

## How to turn on Xdebug
1. By default Xdebug is turned off as turning it on impacts performance.
2. Connect by SSH.
3. Go to ```/usr/local/php/etc/conf.d```,  Update ```xdebug.ini``` as wish, don't modify the path of below line.
```zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so```
4. Save ```xdebug.ini```, Restart apache by below cmd: 
```apachectl restart```
5. Xdebug is turned on.

## Updating WordPress version , themes , files 

If ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = false  ( which is the default setting ) , we recommend you DO NOT update the WordPress core version , themes or files from WordPress admin dashboard. 

Choose either one option to updated your files : 

There is a tradeoff between file server stability and file persistence . 
##### OPTION 1 : 
Since we are using local storage for better stability for the web app , you will not get file persistence.  In this case , we recommend to follow these steps to update WordPress Core  or a theme or a Plugins version :
1.	Fork the repo https://github.com/azureappserviceoss/wordpress-azure 
2.	Clone your repo locally and make sure to use ONLY linux-appservice branch 
3.	Download the latest version of WordPress , plugin or theme being used locally 
4.	Commit the latest version bits into local folder of your cloned repo 
5.	Push your changes to the your forked repo 
6.	Login to Azure portal and select your web app 
7.	Click on Application Settings -> App Settings and change GIT_REPO to use your repository from step #1. If you have changed the branch name , you can continue to use linux-apservice . If you wish to use a different branch , update GIT_BRANCH setting as well. 

##### OPTION 2 :  
You can update ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true  to enable app service storage to have file persistence . Note when there are issues with storage  due to networking or when app service platform is being updated , your app can be impacted . 


## Limitations
- Some unexpected issues may happen after you scale out your site to multiple instances, if you deploy a WordPress site on Azure with this docker image and use the MariaDB built in this docker image as the database.
- The phpMyAdmin built in this docker image is available only when you use the MariaDB built in this docker image as the database.
- Please Include  App Setting ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true  when use built in MariaDB since we need files to be persisted. 
- Please turn off the ARR Affinity option in Application Settings in order for Varnish to cache requsts.

## Change Log
- **Version 0.3-varnish** 
  1. Use Git to deploy wordpress.
  2. Update version of PHP/Apache/Mariadb/Phpmyadmin.
  3. Add Xdebug extenstion of PHP.
  4. Use supervisord to keep SSHD and Apache.
  5. Added a Varnish deamon to allow in-memory caching of HTTP responses for increased performance

# How to Contribute
If you have feedback please create an issue but **do not send Pull requests** to these images since any changes to the images needs to tested before it is pushed to production. 