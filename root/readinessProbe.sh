#! /bin/sh

if [ $(grep 'DEPLOYED' ${MULE_HOME}/logs/*.log | wc -l) -lt 2 ]; then
  exit 1
else
  exit 0
fi