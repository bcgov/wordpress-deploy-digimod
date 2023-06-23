#!/usr/bin/env bash
#set -euo pipefail

if [ ! -z "${OC_ENV}" ] && [ ! -z "${OC_SITE_NAME}" ];  then
    echo >&2 "Project:   ${OC_ENV}"
    echo >&2 "Site Name: ${OC_SITE_NAME}"
    
    whoAmI="$(oc whoami 2> /dev/null)"
    # This means i am logged in.
    if [ ! -z "${whoAmI}" ]; then
    
        printf >&2 "\nStarting Build......with user ${whoAmI}\n"
        echo "Setting up wordpress secrets"
        oc process -p ENV_NAME=${OC_ENV} -p SITE_NAME=${OC_SITE_NAME} -f openshift/templates/secrets/wordpress-secrets.yaml | oc apply -f -
        # ./deployments/kustomize/secrets/secrets.sh
        # mv secrets.txt deployments/kustomize/base/secrets.txt
        cp -r ./deployments/kustomize/overlays/digital-${OC_ENV} ./deployments/kustomize/overlays/digital-${OC_ENV}-bak
        echo "Applying Kustomize configuration"       
        # Inject namePrefix into kustomization.yaml
        sed -i 's/namePrefix:.*$/namePrefix: '$OC_SITE_NAME'-/' ./deployments/kustomize/overlays/digital-${OC_ENV}/kustomization.yaml
        sed -i 's/site:.*$/site: '$OC_SITE_NAME'/' ./deployments/kustomize/overlays/digital-${OC_ENV}/kustomization.yaml
        sed -i 's/name: .*-wordpress-nginx/name: '$OC_SITE_NAME'-wordpress-nginx/' ./deployments/kustomize/overlays/digital-${OC_ENV}/patch.yaml        
        sed -i 's/host: .*/host: '$OC_SITE_NAME'.apps.silver.devops.gov.bc.ca/' ./deployments/kustomize/overlays/digital-${OC_ENV}/patch.yaml
        sed -i 's/APP_DOMAIN=.*$/APP_DOMAIN='$OC_SITE_NAME'.apps.silver.devops.gov.bc.ca/' ./deployments/kustomize/overlays/digital-${OC_ENV}/kustomization.yaml
        sed -i 's/WORDPRESS_DB_HOST=.*$/WORDPRESS_DB_HOST='${OC_SITE_NAME}'-wordpress-mariadb/' ./deployments/kustomize/overlays/digital-${OC_ENV}/kustomization.yaml
        sed -i 's/secretName: .*$/secretName: '${OC_SITE_NAME}'-wordpress-secrets/' ./deployments/kustomize/overlays/digital-${OC_ENV}/patch.yaml
        # Inject namePrefix into patch.yaml
        # sed -i.bak "s|^# *namePrefix:.*$|namePrefix: $OC_SITE_NAME-|g" ./deployments/kustomize/overlays/digital-${OC_ENV}/patch.yaml
        oc apply -k ./deployments/kustomize/overlays/digital-${OC_ENV}
        mv -./deployments/kustomize/overlays/digital-${OC_ENV}-bak ./deployments/kustomize/overlays/digital-${OC_ENV}

    else
        printf >&2 "$(oc whoami)"
    fi
else
    echo >&2 ''
    echo >&2 'Current Variables'
    env | grep -i oc_
    echo >&2 ''
    echo >&2 'Require variables to be set, run: export OC_ENV="test" OC_SITE_NAME="digital-dev"'
fi
