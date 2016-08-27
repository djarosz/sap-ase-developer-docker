FROM debian:jessie

ENV ASE_LOGICAL_PAGE_SIZE=4k ASE_MASTER_DEV_SIZE=300M ASE_TEMPDB_SIZE=4M ASE_DEFAULT_DATA_CACHE_SIZE=2M

ADD /ase.rf /ase.rf
RUN echo "Starting instalation" \
	&& echo "Europe/Warsaw" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends libc6-i386 locales libaio1 libxtst6 curl tar supervisor netcat\
	&& sed -i -s 's/# pl_PL.UTF-8/pl_PL.UTF-8/' /etc/locale.gen \
	&& locale-gen pl_PL.UTF-8 \
	&& curl http://$(ip route|awk '/default/ { print $3 }'):9999/ASE_Suite.linuxamd64.tgz | tar xzf - -C /tmp \
	&& /tmp/ASE_Suite/setup.bin -f /ase.rf -i silent -DAGREE_TO_SAP_LICENSE=true \
	&& apt-get remove -y --purge curl libxtst6 \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /opt/sap/shared/SAPJRE-* \
	&& rm -rf /opt/sap/jre64 \
	&& rm -rf /opt/sap/SCC-* \
	&& rm -rf /opt/sap/sybuninstall \
	&& rm -rf /opt/sap/jConnect-* \
	&& rm -rf /opt/sap/DataAccess* \
	&& rm -rf /opt/sap/ASE-16_0/bin/diag* \
	&& rm -rf /opt/sap/OCS-16_0/devlib* \
	&& rm -rf /tmp/* \
	&& ln -s /opt/sap/SYBASE.sh /etc/profile.d/SYBASE.sh \
	&& mkdir -p /entrypoint.d \
	&& mkdir -p /var/lib/sap/datadir
ADD /rootfs /

VOLUME /var/lib/sap/datadir
VOLUME /opt/sap/log

ENTRYPOINT /entrypoint.sh
EXPOSE 5000
