# Dockerfile for SAP Adaptive Server Enterprise Developer

## Required downloads and packages

Before building this images you have to first download SAP Adaptive Server Enterprise 16.0
Developer edition for Linux (64bit) from 
[SAP Adaptive Server Enterprise Developer Center](http://scn.sap.com/community/developer-center/oltp-db).
Download installer file. Rename it to *ASE_Suite.linuxamd64.tgz* and place it
in root directory alongside with *Dockerfile* and *build.sh*.

You will also need a *busybox* (with httpd support).

## Building

Run ./build.sh

## Creating and running container

Master device is created on first run so it can tak some time to start dependeing on your hardware.

### Create container

```
docker create -p 5000:5000 --name aseserver sap-ase-developer
```

or

```
docker create -p 5000:5000 -v /some/dir:/var/lib/sap/datadir -h aseserver --name aseserver sap-ase-developer
```

#### Available enviroment variables

Thease enviroment variables can be used to tune master device creation. 
Master device is created on first run.

* ***ASE_LOGICAL_PAGE_SIZE*** (Default=4k) - which accepts same values as *dataserver -z* option
* ***ASE_MASTER_DEV_SIZE*** (Default=60M) - whic accepts same values as *dataserver -b* option
* ***ASE_TEMPDB_SIZE*** (Default=4M) - tempdb size
* ***ASE_DEFAULT_DATA_CACHE_SIZE*** (Default=2M) - data cache size 

### Starting / stopping / removing ...

```
docker start aseserver
...
docker stop aseserver
...
docker rm -v aseserver
```

### Connect to database

You can connect to your dataase using this credentials

* Username: sa
* Password:

(default password is empty or empty string)

## Using as base image for other Dockerfiles

This image can be used as base image. Any scripts you place in /entrypoint.d/ will be executed
after master device is created and datserver and backupserver are started. 
Script will be executed in alphabetic order.

If you need to stop/start server during script execution use this globally devined functions:

* start_db_server
* stop_db_server

## Credits

* This Dockerfile is based on [dstore-dbap/sap-ase-docker](https://github.com/dstore-dbap/sap-ase-docker)
