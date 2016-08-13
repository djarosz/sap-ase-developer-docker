#!/bin/bash

if [ ! -e /initialized ]; then
	/ase-init-server.sh
	touch /initialized
fi

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
