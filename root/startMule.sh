#! /bin/sh

# Set JAVA_HOME to avoid mule start issue as wrapper.conf changed wrapper.java.command=%JAVA_HOME%/bin/java
#set JAVA_HOME=/usr/local/openjdk-8/

${MULE_HOME}/bin/mule console

