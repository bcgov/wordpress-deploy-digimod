# Changelog
## April 21, 2023 (DESCW-1014)
- Update WordPress version 6.2, and updated PHP version to 8.0 from 8.2 as this is more widely supported by plugins and themes.

## April 20, 2023 (DESCW-1014)
- Update WordPress version 6.2, and updated PHP version to 8.2 from 7.4
- Update WordPress image build config name to just wordpress

## April 6, 2023 (DESCW-971)
- Backups are now using Kustomize, with updated documentation.

## March 27, 2023 (DESCW-981)
- Adding Kustomize base deployments for local Kubernetes, and OpenShift deployments.
- Removed all referenced to OpenShift deployments, except backups, as they still need to be included with the OpenShift Kustomize deployments.
- Referenced to [OpenShift Template Deployments](https://github.com/bcgov/wordpress/tree/bb8fd6066bcc2087605c50f941b8b906dc0e9b61/openshift/templates) in case the reference is still required

## March 02, 2023 (DESCW-972)
- Removed specific mariadb version from image build to prevent it from failing whenever the alpine package is updated.

## February 7, 2023 (N/A)
- added audit utility
- updated commands.sh to be compatible with .zsh shell

## December 15 2022 (DESCW-716)
- Upgrade wordpress to use v6.1.1

## November 23 2022 (N/A)
- Added PHPMyAdmin container to docker-compose.yaml
- Updated README

## November 02 2022 (DESCW-592)
- Upgrade wordpress to use v6.0.3

## September 15 2022 (DESCW-593)
- Upgrade wordpress to use v6.0.2

## July 27, 2022 (DESSO-467)
- Fixed Nginx config directory
- Added nginx.conf configmap mount for nginx site specific overrides.

## Jul 21, 2022(DESCW-469)
- Bump nginx to version 1.23.1
- Add reference locations for images in openshift templates README.

## Jul 13, 2022 (DESCW-470)
- Disable dependabot automatic pull requests.

## June 29, 2022 (DESCW-443)
- Move php config into wordpress docker build.
- Move mariadb config into mariadb docker build.
- Move nginx config into nginx docker build.

## June 28, 2022 (DESCW-433)
- Dependabot monitoring for docker images.

## June 16, 2022 (DESCW-424)
- Triggers in deployments for image updates.
- updating variable naming so an `env | grep -i oc_` can show all the variables.
- Fixing backup configuration refs
- Fixed mariadb volume mount to readwritemany as this volume is used for multiple databases.
- combined configurations.
