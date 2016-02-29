#!/bin/sh

. parameters.sh

echo -n "Enter the new Drupal version number (eg, X.XX): "
read version

echo -n "New version is '$version' do you want to continue? [y/N]: "
read response

if [ "$response" != "y" ]; then
  echo "bye"
  exit 1
fi

cd $WEB_ROOT

echo "Getting new Drupal"
wget http://ftp.drupal.org/files/projects/drupal-$version.zip

echo "Unzipping new Drupal"
unzip drupal-$version.zip

echo "Copying customisations to new Drupal"
rm -fR drupal-$version/sites
cp -r $SITE_DIRECTORY/sites drupal-$version

if [ -n "$SITE_OWNER" ]; then
    sudo chown -R $SITE_OWNER drupal-$version
fi

echo "Diffing HTACCESS"
diff $SITE_DIRECTORY/.htaccess drupal-$version/.htaccess

echo -n "That was the diff in the .htaccess ('<' in existing; '>' in new). Do you want to continue? [y/N]: "
read response

if [ "$response" != "y" ]; then
  echo "bye"
  exit 1
fi

echo "Diffing Web.Config"
diff $SITE_DIRECTORY/web.config drupal-$version/web.config

echo -n "That was the diff in the web.config ('<' in existing; '>' in new). Do you want to continue? [y/N]: "
read response

if [ "$response" != "y" ]; then
  echo "bye"
  exit 1
fi

echo "Diffing Robots.txt"
diff $SITE_DIRECTORY/robots.txt drupal-$version/robots.txt

echo -n "That was the diff in the robots.txt ('<' in existing; '>' in new). Do you want to continue? [y/N]: "
read response

if [ "$response" != "y" ]; then
  echo "bye"
  exit 1
fi

echo "Diffing Default Settings"
diff $SITE_DIRECTORY/sites/default/default.settings.php drupal-$version/sites/default/default.settings.php

echo -n "That was the diff in the default.settings.php ('<' in existing; '>' in new). Do you want to continue? [y/N]: "
read response

if [ "$response" != "y" ]; then
  echo "bye"
  exit 1
fi

echo "Archiving Existing site..."
mv $SITE_DIRECTORY "$SITE_DIRECTORY"_pre_$version

echo "Moving new site into place..."
mv drupal-$version $SITE_DIRECTORY

if [ ! -f $SITE_DIRECTORY/sites/all/modules/dblib_driver_for_sql_server/dblib ]; then
    ln -s $SITE_DIRECTORY/sites/all/modules/dblib_driver_for_sql_server/dblib $SITE_DIRECTORY/includes/database/dblib
fi

sudo /etc/init.d/uol.apache2 restart

echo "Go to update.php and follow the instructions"
echo "Bye for now"
