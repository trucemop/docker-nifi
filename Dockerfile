# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

FROM centos:7
MAINTAINER Apache NiFi <dev@nifi.apache.org>


RUN yum install -y \
       java-1.8.0-openjdk \
       java-1.8.0-openjdk-devel \
       krb5-server \
       krb5-libs \
       krb5-auth-dialog \
       krb5-workstation

ENV JAVA_HOME /etc/alternatives/jre

ARG UID=1000
ARG GID=50
ARG NIFI_VERSION=1.2.0.3.0.1.0-43

ENV NIFI_BASE_DIR /opt/nifi
ENV NIFI_HOME $NIFI_BASE_DIR/nifi-$NIFI_VERSION
ENV NIFI_BINARY_URL https://public-repo-1.hortonworks.com/HDF/3.0.1.0/nifi-${NIFI_VERSION}-bin.tar.gz

# Setup NiFi user
RUN groupadd -g $GID nifi || groupmod -n nifi `getent group $GID | cut -d: -f1`
RUN useradd --shell /bin/bash -u $UID -g $GID -m nifi
RUN mkdir -p $NIFI_HOME

# Download, validate, and expand Apache NiFi binary.
RUN curl -fSL $NIFI_BINARY_URL -o $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz \
	&& tar -xvzf $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz -C $NIFI_BASE_DIR \
	&& rm $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz


RUN chown -R nifi:nifi $NIFI_HOME


# Web HTTP Port
EXPOSE 8080

# Remote Site-To-Site Port
EXPOSE 8181

USER nifi

# Startup NiFi
CMD $NIFI_HOME/bin/nifi.sh run
