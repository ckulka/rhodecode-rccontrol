FROM centos:7
LABEL maintainer="cyrill.kulka@gmail.com"

ENV RC_INSTALLER    RhodeCode-installer-linux-build20200525_1200
ENV RC_CHECKSUM     32d02e72eced73dc708e02ff4a10af265e392d4bb87c88c0ed89c5dcb0cc608e

# Create the RhodeCode user
RUN     yum update -y \
        && yum install python2 bzip2 postgresql   -y \
        && yum clean all

RUN useradd rhodecode -u 1000 -s /sbin/nologin		        \
                && mkdir -m 0755 -p /opt/rhodecode /data	        \
		&& chown rhodecode:rhodecode /opt/rhodecode /data	\
		&& curl -so /usr/local/bin/crudini https://raw.githubusercontent.com/pixelb/crudini/0.9.3/crudini \
		&& chmod +x /usr/local/bin/crudini

USER rhodecode
WORKDIR /home/rhodecode

# Install RhodeCode Control
RUN curl -so $RC_INSTALLER "https://dls-eu.rhodecode.com/dls/NjY2YjY4NzI3MDc4NjY0MDc0N2E2ZTc2NzkyZTcwNjI3YQ==/rhodecode-control/latest-linux-ee" \
		&& echo "$RC_CHECKSUM *$RC_INSTALLER" |  sha256sum -c -	\
		&& chmod 755 $RC_INSTALLER								\
		&& ./$RC_INSTALLER --accept-license						\
		&& rm $RC_INSTALLER

# Add additional tools
COPY files .
