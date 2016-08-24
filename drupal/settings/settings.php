<?php
// Include a settings.php that is part of the repository.
if (file_exists(__DIR__ . '/settings.dork.php')) {
   include __DIR__ . '/settings.dork.php';
}

// Include local settings if available.
if (file_exists(__DIR__ . '/settings.local.php')) {
   include __DIR__ . '/settings.local.php';
}

// Set the private file path outside of the docroot.
$settings['file_private_path'] = '/private';


// Database settings configured by container environment.
$databases['default']['default'] = array (
  'database' => getenv('MYSQL_DATABASE'),
  'username' => getenv('MYSQL_USER'),
  'password' => getenv('MYSQL_PASSWORD'),
  'prefix' => '',
  'host' => getenv('MYSQL_HOST'),
  'port' => getenv('MYSQL_PORT'),
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);


// Drupal 8 specific settings.
if (getenv('DRUPAL_VERSION') == "8") {
  $settings['hash_salt'] = 'dork';
  $settings['install_profile'] = getenv('DRUPAL_INSTALL_PROFILE');
  $config_directories['sync'] = getenv('DRUPAL_CONFIG_DIR');
}
else {
  $drupal_hash_salt = 'dork';
}

if (getenv('DEVELOPMENT') == 'yes') {
  include '/dork/drupal/settings.development.php';
}

