<?php
if (getenv('DRUPAL_VERSION') == "7") {
  // Disable javascript and css aggregation.
  $conf['preprocess_css'] = FALSE;
  $conf['preprocess_js'] = FALSE;

  if (!class_exists('DrupalFakeCache')) {
    $conf['cache_backends'][] = 'includes/cache-install.inc';
  }
  // Default to throwing away cache data
  $conf['cache_default_class'] = 'DrupalFakeCache';

  // Rely on the DB cache for form caching - otherwise forms fail.
  $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
}
else {
  $conf['preprocess_css'] = TRUE;
  $conf['preprocess_js'] = TRUE;
}

if (getenv('DRUPAL_VERSION') == "8") {
  // Enable asserts.
  assert_options(ASSERT_ACTIVE, TRUE);
  \Drupal\Component\Assertion\Handle::register();

  // Show test modules/themes.
  $settings['extension_discovery_scan_tests'] = TRUE;

  // Access rebuild.php
  $settings['rebuild_access'] = TRUE;

  // Don't try to chmod settings.php all the time.
  $settings['skip_permissions_hardening'] = TRUE;

  // Log all the things.
  $config['system.logging']['error_level'] = 'verbose';

  // Load development settings with twig caching disabled and the
  // "null" cache backend.
  $settings['container_yamls'][] = '/dork/drupal/services.development.yml';

  // Set caching to null.
  $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
  $settings['cache']['bins']['render'] = 'cache.backend.null';

  // Don't preprocess javascript and css assets.
  $config['system.performance']['css']['preprocess'] = FALSE;
  $config['system.performance']['js']['preprocess'] = FALSE;

}
