#!/bin/bash

. /opt/sap/SYBASE.sh

ASE_DATADIR=/var/lib/sap/datadir
exec backupserver -SSYB_BACKUP -e$APP_DATADIR/SYB_BACKUP.log
