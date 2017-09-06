FROM centos:7
LABEL maintainer="cyrill.kulka@gmail.com"

ENV RC_DATA		"/data"
ENV RC_APP		"undefined"
ENV RC_VERSION	"4.9.0"
ENV RC_USER		"admin"
ENV RC_PASSWORD	"adalovelace"
ENV RC_DB		"sqlite"

ENV RC_INSTALLER	RhodeCode-installer-linux-build20170813_2100
ENV RC_CHECKSUM		75ee77b0abbf59582b9060d381c5f80b60fd9d3e7f5040b9685617cb7296d2db

RUN useradd rhodecode -u 1000 -s /sbin/nologin				\
	&& mkdir -m 0755 -p /opt/rhodecode $RC_DATA				\
	&& chown rhodecode:rhodecode /opt/rhodecode $RC_DATA	\
	&& yum install -y bzip2

USER rhodecode
WORKDIR /home/rhodecode

RUN curl -so $RC_INSTALLER https://dls-eu.rhodecode.com/dls/NzA2MjdhN2E2ODYxNzY2NzZjNDA2NTc1NjI3MTcyNzA2MjcxNzIyZTcwNjI3YQ==/rhodecode-control/latest-linux-ce \
	&& echo "$RC_CHECKSUM *$RC_INSTALLER" |  sha256sum -c -	\
	&& chmod 755 $RC_INSTALLER								\
	&& ./$RC_INSTALLER --accept-license						\
	&& rm $RC_INSTALLER

COPY start.sh /home/rhodecode/
CMD ["bash", "start.sh"]