#!/usr/bin/env bash

JBOSS_USER=jboss
FILE="elasticsearch-1.2.1"

# https://community.jboss.org/thread/237948
echo "wget -v https://download.elasticsearch.org/elasticsearch/elasticsearch/$FILE.tar.gz -o /tmp/$FILE.tar.gz"
wget -v https://download.elasticsearch.org/elasticsearch/elasticsearch/$FILE.noarch.rpm -O /tmp/$FILE.noarch.rpm
echo "Elastichsearch binary downloaded in /tmp/$FILE.noarch.rpm"

echo "Installing"
rpm -ivh /tmp/$FILE.noarch.rpm 

sed -i -e "s/ES_USER=.*/ES_USER=${JBOSS_USER}/g" /etc/sysconfig/elasticsearch

# Register and run the server
/sbin/chkconfig --add elasticsearch
service elasticsearch start

# TODO: Wait until server started


# Configure the server
#curl -XPUT 'http://localhost:9200/rtgov'

#curl -XPUT 'http://localhost:9200/rtgov/responsetime/_mapping' -d '    
#{  
#      "responsetime" : {  
#        "properties" : {  
#          "serviceType" : {  
#            "type" : "string",  
#            "index" : "not_analyzed"  
#          }  
#        }  
#      }  
#}  
#' 
#
#wget https://community.jboss.org/servlet/JiveServlet/download/861903-117984/samples-elasticsearch-fsw.zip -o /tmp/samples-elasticsearch-fsw.zip



