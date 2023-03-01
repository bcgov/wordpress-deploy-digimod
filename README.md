# Digimod WordPress deployments

This is a fork of GDX [WordPress Deployments Repo](https://github.com/bcgov/wordpress) customized for deployments with digital.gov.bc.ca

# OpenShift deployment steps:

## Create base images 
(replace "fd34fb" with your project namespace). You can also optionally specify project name (default is "wordpress") via APP_NAME. Images will be created in the "test" namespace:

`oc process -p PROJECT_NAMESPACE="fd34fb" -p APP_NAME="wordpress" -f openshift/templates/dockerhub-imagestreams/alpine.yaml | oc apply -f -`

`oc process -p PROJECT_NAMESPACE="fd34fb" -p APP_NAME="wordpress" -f openshift/templates/dockerhub-imagestreams/wordpress.yaml | oc apply -f -`

`oc process -p PROJECT_NAMESPACE="fd34fb" -p APP_NAME="wordpress" -f openshift/templates/dockerhub-imagestreams/nginx.yaml | oc apply -f -`

`oc process -p PROJECT_NAMESPACE="fd34fb" -p APP_NAME="wordpress" -f openshift/templates/dockerhub-imagestreams/ubuntu.yaml | oc apply -f -`

## Rename images to test/prod if it's not dev:

`oc -n fd34fb-tools tag wordpress-mariadb-run:dev wordpress-mariadb-run:test`

`oc -n fd34fb-tools tag wordpress-nginx-run:dev wordpress-nginx-run:test`

`oc -n fd34fb-tools tag wordpress-wordpress-run:dev wordpress-wordpress-run:test`

`oc -n fd34fb-tools tag wordpress-sidecar-run:dev wordpress-sidecar-run:test`


## Create builds. 

Replace "dev" with your deployment target ("test" or "prod") - this will assign appropriate tag:

`oc process -p PROJECT_NAMESPACE="fd34fb" -p IMAGE_TAG="dev" -p APP_NAME="wordpress" -f openshift/templates/images/mariadb/build.yaml | oc apply -f -`

`oc process -p PROJECT_NAMESPACE="fd34fb" -p IMAGE_TAG="dev" -p APP_NAME="wordpress" -f openshift/templates/images/nginx/build.yaml | oc apply -f -`

`oc process -p PROJECT_NAMESPACE="fd34fb" -p IMAGE_TAG="dev" -p APP_NAME="wordpress" -f openshift/templates/images/wordpress/build.yaml | oc apply -f -`

`oc process -p PROJECT_NAMESPACE="fd34fb" -p IMAGE_TAG="dev" -p APP_NAME="wordpress" -f openshift/templates/images/sidecar/build.yaml | oc apply -f -`

## Run builds 
(may need to replace "wordpress" with a different app name if it was changed above):

`oc -n fd34fb-tools start-build wordpress-mariadb-run`

`oc -n fd34fb-tools start-build wordpress-nginx-run`

`oc -n fd34fb-tools start-build wordpress-wordpress-run`

`oc -n fd34fb-tools start-build wordpress-sidecar-run`

`oc -n fd34fb-tools start-build wordpress-sidecar-run`

## Deploy mariaDB:
Create a secret with auto-generated passwords:

`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -f openshift/templates/mariadb/secrets.yaml | oc apply -f -`

## Create volume:
`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -f openshift/templates/mariadb/volume.yaml | oc apply -f -`

## Deploy mariaDB and create the service:
`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -f openshift/templates/mariadb/deploy.yaml | oc apply -f -`

## Create wordpress config:

`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_DOMAIN=testwwp-dev.apps.silver.devops.gov.bc.ca -p WORDPRESS_MULTISITE=0 -f openshift/templates/config/config.yaml | oc apply --overwrite=false -f -`

## Create Nginx route:
`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -p APP_DOMAIN=testwwp-dev.apps.silver.devops.gov.bc.ca -f openshift/templates/nginx/deploy-route.yaml | oc apply -f -`

## Create Wordpress secrets with automatically generated passwords:
`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -f openshift/templates/wordpress/secrets.yaml | oc apply -f -`

## Create WordPress volume
`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -f openshift/templates/wordpress/volume.yaml | oc apply -f -`

## Deploy wordpress:
`oc process -p PROJECT_NAMESPACE="fd34fb" -p ENV_NAME="dev" -p APP_NAME="wordpress" -f openshift/templates/wordpress/deploy-nginx-wordpress.yaml | oc apply -f -`

## Backups
Create cron job for database backups:

`oc process -p ENV_NAME=prod -p SITE_NAME=wordpress -p POOL_NAME=wordpress-pool  -f openshift/templates/backups/cron.yaml | oc apply -f -`

Create backup volume and verification volume:

`oc process -p ENV_NAME=prod -p POOL_NAME=wordpress-pool -f openshift/templates/backups/volume-backup.yaml | oc apply -f -`

Create 

To deploy sidecar (test):

`oc process -p ENV_NAME=test -p SITE_NAME=des -p POOL_NAME=pool-name -p RUN_AS_USER=1004880000 -f openshift/templates/sidecar/deploy.yaml | oc apply -f -`

prod sidecar:

`oc process -p ENV_NAME=prod -p SITE_NAME=wordpress -p POOL_NAME=wordpress-pool -p RUN_AS_USER=1004870000 -f openshift/templates/sidecar/deploy.yaml | oc apply -f -`

Files are backed up through the use of the `netapp-file-backup`. To create a manual backup of the files (inside sidecar):

`rsync -a /var/www/html/ /home/sidecar/backups/html/`

Database backup runs via a chronjob daily. To create a manual backup of the database:

`oc create job --from=cronjob/wordpress-mariadb-cron--des wordpress-mariadb-cron--des-manual`

To restore database:

`gzip -cd ~/backups/db/daily/test.sql.gz | mysql -u $WORDPRESS_DB_USER -p$(cat $MYSQL_PASSWORD_FILE) -h wordpress-mariadb $WORDPRESS_DB_NAME`

Example of this command on test:

` gzip -cd wordpress-mariadb--des-des_test_2023-03-01_02-30-21.sql.gz | mysql -uroot -p[PASSWORD] -h wordpress-mariadb--des des_test`

todo: add instructions for adding the sso plugin and adding relevant themes/other plugins.
