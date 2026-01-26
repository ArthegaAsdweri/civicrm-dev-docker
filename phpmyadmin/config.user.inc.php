<?php
/**
 * Custom phpMyAdmin config. Adds an extra server via SSH tunnel.
 * Keep this minimal so it does not interfere with docker env defaults.
 */

# Next free server index
$i = 1;
while (isset($cfg['Servers'][$i])) {
  $i++;
}


$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['verbose'] = 'SSH Tunnel (extern)';
$cfg['Servers'][$i]['host'] = 'host.docker.internal';
$cfg['Servers'][$i]['port'] = '3307';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;

// Wenn du TLS am DB-Server nutzt, wäre hier der Ort für SSL-Optionen.
