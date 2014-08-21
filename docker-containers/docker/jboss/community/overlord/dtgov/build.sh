#!/bin/bash

if [ ! -f files/dtgov-1.3.0.Final.zip]
then
   wget http://downloads.jboss.org/overlord/dtgov/dtgov-1.3.0.Final.zip -P files
fi

if [ ! -f files/s-ramp-0.5.0.Final.zip ]
then
   wget http://downloads.jboss.org/overlord/sramp/s-ramp-0.5.0.Final.zip -P files
fi

docker build --rm -t jboss.org/dtgov:1.3.0  .
