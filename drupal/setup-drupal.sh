#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
. /dork/init/setup-php.sh

SITE_PATH="$DOCROOT"/sites/"$DRUPAL_SITE"

# If there is no settings.php, copy  default.settings.php.
if [ -f "$SITE_PATH"/default.settings.php ] && ! [ -f "$SITE_PATH"/settings.php ]; then
  echo "Copying default.settings.php."
  cp "$SITE_PATH"/default.settings.php "$SITE_PATH"/settings.php
fi

# If there already is a settings.php, move it to settings.dork.php, which
# will be included by the container internal settings.php.
if [ -f "$SITE_PATH"/settings.php ] && ! [ -f "$SITE_PATH"/settings.dork.php ]; then
  echo "Moving existing settings.php to settings.dork.php."
  mv "$SITE_PATH"/settings.php "$SITE_PATH"/settings.dork.php
fi

# Copy the internal settings.php.
if ! [ -f "$SITE_PATH"/settings.php ]; then
  echo "Copying internal settings.php into $SITE_PATH."
  cp /dork/drupal/settings.php "$SITE_PATH"/settings.php
fi

# Check if the database is empty.
if [[ -n "$MYSQL_USER" && -n "$MYSQL_PASSWORD" && -n "$MYSQL_HOST" && -n "$MYSQL_DATABASE" ]]; then
  tables=$(mysql -N -B -u "$MYSQL_USER" -h "$MYSQL_HOST" -p"$MYSQL_PASSWORD"  -D "$MYSQL_DATABASE" -e "SHOW TABLES;")
  if [[ $tables ]]; then
    echo "Drupal is already installed."
  else
    if [ -f /import/drupal.sql ]; then
      echo "Database dump available. Running import."
      # If there is a drupal.sql import it, instead of running a full install.
      mysql -u "$MYSQL_USER" -h "$MYSQL_HOST" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < /import/drupal.sql
      echo "Database import complete."

      # Import public files directory.
      if [ -d /import/public ]; then
        echo "Importing public files directory."
        cp -af /import/public/* "$SITE_PATH/files"
      fi

      # Import private files directory.
      if [ -d /import/private ]; then
        echo "Importing private files directory."
        cp -af /import/private/* /private
      fi
    else
      # No database dump available, install everything from scratch.
      if [ -d "$DRUPAL_CONFIG_DIR" ]; then
        DRUPAL_INSTALL_PARAMS="$DRUPAL_INSTALL_PARAMS --config-dir=$DRUPAL_CONFIG_DIR"
      fi

      # Run installation with provided environment variables.
      drush si -y \
        --account-name="$DRUPAL_ADMIN_USER" \
        --account-pass="$DRUPAL_ADMIN_PASSWORD" \
        "$DRUPAL_INSTALL_PROFILE" \
        "$DRUPAL_INSTALL_PARAMS"

      # Override drush-generated settings.php
      echo "Overriding drush generated settings.php with container internal."
      cp /dork/drupal/settings.php "$SITE_PATH"/settings.php
    fi
  fi
else
  echo "No database crendentials provided. Skipping installation."
fi

# Make development mode adjustements. 
if [ "$DEVELOPMENT" == "yes" ]; then

  # Disable production modules.
  if [ -n "$DRUPAL_PRODUCTION_MODULES" ]; then
    if [ "$DRUPAL_VERSION" == "8" ]; then
      drush pm-uninstall $DRUPAL_PRODUCTION_MODULES -y
    else
      drush pm-disable $DRUPAL_PRODUCTION_MODULES -y
      drush pm-uninstall $DRUPAL_PRODUCTION_MODULES -y
    fi
  fi

  # Enable development modules.
  if [ -n "$DRUPAL_DEVELOPMENT_MODULES" ]; then
    drush pm-enable $DRUPAL_DEVELOPMENT_MODULES -y
  fi

# Configure container for production.
else

  # Disable development modules.
  if [ -n "$DRUPAL_DEVELOPMENT_MODULES" ]; then
    if [ "$DRUPAL_VERSION" == "8" ]; then
      drush pm-uninstall $DRUPAL_DEVELOPMENT_MODULES -y
    else
      drush pm-disable $DRUPAL_DEVELOPMENT_MODULES -y
      drush pm-uninstall $DRUPAL_DEVELOPMENT_MODULES -y
    fi
  fi
  # Enable production modules.
  if [ -n "$DRUPAL_PRODUCTION_MODULES" ]; then
    drush pm-enable $DRUPAL_PRODUCTION_MODULES -y
  fi
fi

# Clear the cache, depending on drupal version.
if [ "$DRUPAL_VERSION" == "8" ]; then
  drush cr
fi

if [ "$DRUPAL_VERSION" == "7" ]; then
  drush cc all
fi

# Make mounted files directories writable to apache user.
# TODO: Find a better solution. Unfortunately mounts are
# always owned by root.
if [ -d /private ]; then
  chown www-data:www-data /private
fi

if [ -d "$SITE_PATH"/files ]; then
  chown www-data:www-data "$SITE_PATH"/files
fi
