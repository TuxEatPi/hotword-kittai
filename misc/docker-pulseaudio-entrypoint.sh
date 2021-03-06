#!/bin/bash
set -e

if [ "$1" = 'tep' ]; then
	USER_UID=${USER_UID:-1000}
	USER_GID=${USER_GID:-1000}

	# create user group
	if ! getent group tep >/dev/null; then
		groupadd -f -g ${USER_GID} tep
	fi

	# create user with uid and gid matching that of the host user
	if ! getent passwd tep >/dev/null; then
		adduser --uid ${USER_UID} --gid ${USER_GID} \
			--disabled-login \
			--gecos 'TuxEatPi' tep

#		ln -s /data/cache /home/tep/.cache
#		ln -s /data/config /home/tep/.config
	fi

#	chown -R tep:tep /data

#	exec su tep -c "$@"
    exec su tep -c "tep-hotword-kittai -w /tmp -I /intents -D /dialogs"

fi

exec "$@"
