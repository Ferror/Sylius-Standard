#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
	mkdir -p var/cache var/log var/sessions public/media
	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var public/media
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var public/media

# This is in the Dockerfile
#	if [ "$APP_ENV" != 'prod' ]; then
#		composer install --prefer-dist --no-progress --no-interaction --no-dev
#		bin/console assets:install --no-interaction
#		bin/console sylius:theme:assets:install public --no-interaction
#	fi

	until bin/console doctrine:query:sql "select 1" >/dev/null 2>&1; do
	    (>&2 echo "Waiting for MySQL to be ready...")
		sleep 1
	done

# THESE SHOULD BE RUN BY ONLY ONE SERVICE
#    bin/console doctrine:migrations:migrate --no-interaction
#    bin/console sylius:fixtures:load --no-interaction
fi

exec docker-php-entrypoint "$@"
