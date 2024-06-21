#!/bin/bash

LOG_FILE="/var/log/cloudera-OCI-initialize.log"
log() { 
	echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}" 
}


log "->Deployment Script Decode"
curl -L http://169.254.169.254/opc/v1/instance/metadata/deploy_on_oci | base64 -d > /var/lib/cloud/instance/scripts/deploy_on_oci.py.gz
log "-->Extract"
gunzip /var/lib/cloud/instance/scripts/deploy_on_oci.py.gz >> $LOG_FILE

log "->CMS Setup Script Decode"
curl -L http://169.254.169.254/opc/v1/instance/metadata/cm_install | base64 -d > /var/lib/cloud/instance/scripts/cms_mysql.sh.gz
log "-->Extract"
gunzip /var/lib/cloud/instance/scripts/cms_mysql.sh.gz >> $LOG_FILE
chmod +x /var/lib/cloud/instance/scripts/cms_mysql.sh


EXECNAME="CMS Setup"
log "->Execute"
cd /var/lib/cloud/instance/scripts/
./cms_mysql.sh
