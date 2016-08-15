#!/bin/bash

function start_db_server {
	echo "Starting DB server"
	(
		cd /
		/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &
		sleep 1
		while ! echo | nc -z localhost 5000; do sleep 1; echo "Waiting for server to start ..."; done
		sleep 1
	)
	echo "DB server startted"

}

function stop_db_server {
	echo "Stopping DB server"
	(
		cd /
		if [ -e /supervisord.pid ]; then
			ASE_PID=$(cat /supervisord.pid)
			kill $ASE_PID
			wait $ASE_PID
		else 
			echo "DB server already stopped"
		fi
		sleep 1
	)
	echo "DB server stopped"
}

. /opt/sap/SYBASE.sh

ASE_DATADIR=/var/lib/sap/datadir

dataserver \
	-d$ASE_DATADIR/master.dat \
	-b$ASE_MASTER_DEV_SIZE \
	-z$ASE_LOGICAL_PAGE_SIZE \
	-e$ASE_DATADIR/SYBASE.log \
	-c$ASE_DATADIR/SYBASE.cfg \
	-M$ASE_DATADIR/ \
	-sSYBASE

start_db_server

isql -Usa -P --retserverror -SSYBASE << EOF 
disk init name = "tempdev2", physname = "$ASE_DATADIR/tempdb.dat", cntrltype = 0, dsync = true, size = "$ASE_TEMPDB_SIZE"
go
alter database tempdb on tempdev2 = "$ASE_TEMPDB_SIZE"
go
EOF


isql -Usa -P --retserverror -SSYBASE << EOF
disk init name = "sysprocsdev", physname = "$ASE_DATADIR/sysprocs.dat", size = "180M"
go
create database sybsystemprocs on sysprocs = 180
go
EOF

isql -Usa -P --retserverror -SSYBASE -n -i /opt/sap/ASE-16_0/scripts/installmaster
isql -Usa -P --retserverror -SSYBASE -n -i /opt/sap/ASE-16_0/scripts/installmodel
isql -Usa -P --retserverror -SSYBASE -n -i /opt/sap/ASE-16_0/scripts/instmsgs.ebf
isql -Usa -P --retserverror -SSYBASE -n -i /opt/sap/ASE-16_0/scripts/installupgrade

isql -Usa -P --retserverror -SSYBASE << EOF 
sp_cacheconfig 'default data cache', '$ASE_DEFAULT_DATA_CACHE_SIZE'
go
use tempdb
go
sp_dropsegment "default", tempdb, master
go
sp_dropdegment system, tempdb, master
go
sp_dropdegment logsegment, tempdb, master
go
EOF

echo "Executing scripts in /entrypoint.d"
for script in $(find /entrypoint.d -maxdepth 1 -type f | sort); do
	echo "Executing script: $script"
	. $script
done
echo "Finished executing scripts in /entrypoint.d"

stop_db_server
