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
