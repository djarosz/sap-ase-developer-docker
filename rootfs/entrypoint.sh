#!/bin/bash

FLAG_FILE=/var/lib/sap/datadir/initialized_flag

if [ ! -e $FLAG_FILE ]; then
	/ase-init-server.sh
	touch $FLAG_FILE
fi

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
