#!/bin/bash

. /opt/sap/SYBASE.sh

ASE_DATADIR=/var/lib/sap/datadir
exec dataserver \
	-d$ASE_DATADIR/master.dat \
	-e$ASE_DATADIR/SYBASE.log \
	-c$ASE_DATADIR/SYBASE.cfg \
	-M$ASE_DATADIR/ \
	-sSYBASE
