<?php

/* Servers configuration */
$i = 0;

/* Server: localhost [1] */
$i++;
#$cfg['PmaAbsoluteUri'] = 'localhost/phpmyadmin';

/* http://stackoverflow.com/questions/1819592/error-when-connecting-to-mysql-using-php-pdo/1819767#1819767 */
$cfg['Servers'][$i]['host'] = '127.0.0.1';
$cfg['Servers'][$i]['port'] = '';
$cfg['Servers'][$i]['connect_type'] = 'socket';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['AllowRoot'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;

/* End of servers configuration */

$cfg['blowfish_secret'] = '"|5o$cGlh7%j"f"BKN)5cY%-(&,T(yh%';
$cfg['DefaultLang'] = 'en';
$cfg['ServerDefault'] = 1;
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

/* https://boss.vvc.edu/database_access/doc/html/config.html#cfg_CheckConfigurationPermissions */
$cfg['CheckConfigurationPermissions']=false;

$cfg['ForceSSL']=false;

?>
