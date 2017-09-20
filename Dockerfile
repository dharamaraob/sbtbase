FROM alpine:3.5
MAINTAINER Dharamarao<dharmaraobala@gmail.com>

# Install root filesystem
ADD ./rootfs /

# Install base packages
RUN apk update && apk upgrade && \
    apk add curl wget bash tree && \
    echo -ne "Alpine Linux 3.5 image. (`uname -rsv`)\n" >> /root/.built


# Java Version
ENV JAVA_VERSION=8 JAVA_UPDATE=45 JAVA_BUILD=14 JAVA_PACKAGE=server-jre JAVA_HOME=/usr/lib/jvm/default-jvm

# Set environment
ENV PATH=${PATH}:${JAVA_HOME}/bin

ENV SBT_VERSION 0.13.15
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin


# Copy apks
COPY /lib /var/cache/apk

# Install Glibc and Oracle server-jre 8
WORKDIR /usr/lib/jvm
CMD ["/bin/bash"]
RUN apk add --update libgcc 
RUN apk add --allow-untrusted /var/cache/apk/glibc-2.21-r2.apk
RUN apk add --allow-untrusted /var/cache/apk/glibc-bin-2.21-r2.apk 
RUN /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \ 
    "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz"
RUN    tar xzf "${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz"
RUN    mv "jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" java-${JAVA_VERSION}-oracle
RUN    ln -s "java-${JAVA_VERSION}-oracle" $JAVA_HOME
RUN    apk del libgcc
RUN    rm -f ${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz && \
    rm -f /var/cache/apk/* && \
    rm -rf default-jvm/*src.zip \
           default-jvm/lib/missioncontrol \
           default-jvm/lib/visualvm \
           default-jvm/lib/*javafx* \
           default-jvm/jre/lib/plugin.jar \
           default-jvm/jre/lib/ext/jfxrt.jar \
           default-jvm/jre/bin/javaws \
           default-jvm/jre/lib/javaws.jar \
           default-jvm/jre/lib/desktop \
           default-jvm/jre/plugin \
           default-jvm/jre/lib/deploy* \
           default-jvm/jre/lib/*javafx* \
           default-jvm/jre/lib/*jfx* \
           default-jvm/jre/lib/amd64/libdecora_sse.so \
           default-jvm/jre/lib/amd64/libprism_*.so \
           default-jvm/jre/lib/amd64/libfxplugins.so \
           default-jvm/jre/lib/amd64/libglass.so \
           default-jvm/jre/lib/amd64/libgstreamer-lite.so \
           default-jvm/jre/lib/amd64/libjavafx*.so \
           default-jvm/jre/lib/amd64/libjfx*.so && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    echo -ne "- with `java -version 2>&1 | awk 'NR == 2'`\n" >> /root/.built

RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

WORKDIR /root
# Define bash as default command
CMD ["/bin/bash"]