#FROM openjdk:8
#FROM redhat-openjdk-18/openjdk18-openshift
FROM openshift/base-centos7

ENV SUMMARY="Mule ESB Community Edition 4.1.1 Runtime" \
    DESCRIPTION="Mule ESB Runtime is a free and open-source \
container image contains programs to run Mule Apps."

LABEL name="Mule esb runtime 4.1.1" \
### Required labels above - recommended below
      url="https://github.com/dkudale/mule-docker.git" \
      run='docker run -tdi --name ${NAME} \
      -u 10001 \
      ${IMAGE}' \
      io.k8s.description="Mule ESB App 4.1.1" \
      io.k8s.display-name="Mule ESB App 4.1.1" \
      io.openshift.expose-services="" \
      io.openshift.tags="mule 4.1.1" \
      usage="docker run -d rhscl/mule-411"

ENV MULE_HOME=/opt/mule-standalone-4.1.1 \
    MULE_RUNTIME_VERSION=4.1.1 \
    MAVEN_VERSION=3.3.9 \
    JAVA_HOME=/usr/lib/jvm/java-1.8.0

RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    (curl -v https://www.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /opt/s2i/destination

RUN cd ~/ && wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.1.1/mule-standalone-4.1.1.tar.gz
RUN cd /opt && tar xvzf ~/mule-standalone-4.1.1.tar.gz
#RUN echo "6b5c3ae9c87f95b00f0c1aff300ca70c550f1952 ~/mule-standalone-4.1.1.tar.gz" | md5sum -c

RUN rm ~/mule-standalone-4.1.1.tar.gz

RUN mkdir -p /opt/mule-standalone-4.1.1/scripts
COPY ./root/startMule.sh /opt/mule-standalone-4.1.1/scripts/

COPY ./root/livenessProbe.sh /opt/bin/
COPY ./root/readinessProbe.sh /opt/bin/

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chmod +x $STI_SCRIPTS_PATH/assemble $STI_SCRIPTS_PATH/run $STI_SCRIPTS_PATH/save-artifacts $STI_SCRIPTS_PATH/usage

# Copy extra files to the image.
COPY ./root/ /

RUN chmod -R u+x ${MULE_HOME}/scripts && \
    chgrp -R 0 ${MULE_HOME} && \
    chmod -R g=u ${MULE_HOME} /etc/passwd

RUN chown -R 1001:0 /opt/mule-standalone-4.1.1 /opt/bin && chown -R 1001:0 $HOME && \
    chmod -R ug+rwX /opt/mule-standalone-4.1.1 /opt/bin && \
    chmod -R g+rw /opt/s2i/destination && \
    chmod -R u+x $STI_SCRIPTS_PATH/ /opt/bin /opt/mule-standalone-4.1.1

USER 1001

# Not using VOLUME statement since it's not working in OpenShift Online:
# https://github.com/sclorg/httpd-container/issues/30
# Define mount points.
#VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]
EXPOSE 8081

CMD $STI_SCRIPTS_PATH/usage