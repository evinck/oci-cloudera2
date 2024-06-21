#!/bin/bash

# Logfile
LOG_FILE="/var/log/cloudera-OCI-initialize.log"
log() { 
	echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}" 
}

# Get the variables
cm_fqdn=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cloudera_manager`
fqdn_fields=`echo -e $cm_fqdn | gawk -F '.' '{print NF}'`
cluster_domain=`echo -e $cm_fqdn | cut -d '.' -f 3-${fqdn_fields}`
cm_ip=`host ${cm_fqdn} | gawk '{print $4}'`
cluster_subnet=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cluster_subnet`
bastion_subnet=`curl -L http://169.254.169.254/opc/v1/instance/metadata/bastion_subnet`
utility_subnet=`curl -L http://169.254.169.254/opc/v1/instance/metadata/utility_subnet`
cloudera_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cloudera_version`
cloudera_major_version=`echo $cloudera_version | cut -d '.' -f1`
cm_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cm_version`
cm_major_version=`echo  $cm_version | cut -d '.' -f1`
# Note that the AD detection depends on the subnet containing the AD as the last character in the name
worker_shape=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_shape`
worker_disk_count=`curl -L http://169.254.169.254/opc/v1/instance/metadata/block_volume_count`
secure_cluster=`curl -L http://169.254.169.254/opc/v1/instance/metadata/secure_cluster`
hdfs_ha=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hdfs_ha`
cluster_name=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cluster_name`
cm_username=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cm_username`
cm_password=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cm_password`
vcore_ratio=`curl -L http://169.254.169.254/opc/v1/instance/metadata/vcore_ratio`
debug=`curl -L http://169.254.169.254/opc/v1/instance/metadata/enable_debug`
yarn_scheduler=`curl -L http://169.254.169.254/opc/v1/instance/metadata/yarn_scheduler`
full_service_list=(ATLAS HBASE HDFS HIVE IMPALA KAFKA OOZIE RANGER SOLR SPARK_ON_YARN SQOOP_CLIENT YARN)
service_list="ZOOKEEPER"
rangeradmin_password=''
for service in ${full_service_list[@]}; do
        svc_check=`curl -L http://169.254.169.254/opc/v1/instance/metadata/svc_${service}`
        if [ $svc_check  = "true" ]; then
		if [ $service = "RANGER" ]; then 
			rangeradmin_password=`curl -L http://169.254.169.254/opc/v1/instance/metadata/rangeradmin_password`
			ranger_enabled="true"
			service_list=`echo -e "${service_list},${service}"`
		elif [ $service = "ATLAS" ]; then 
			atlas_enabled="true"
			service_list=`echo -e "${service_list},${service}"`
		else
			service_list=`echo -e "${service_list},${service}"`
		fi
		
        fi
done;


EXECNAME="KERBEROS"
log "-> INSTALL"
yum -y install krb5-server krb5-libs krb5-workstation >> $LOG_FILE
KERBEROS_PASSWORD="SOMEPASSWORD"
SCM_USER_PASSWORD="somepassword"
kdc_fqdn=${cm_fqdn}
realm="hadoop.com"
REALM="HADOOP.COM"

rm -f /var/kerberos/krb5kdc/kdc.conf
cat > /var/kerberos/krb5kdc/kdc.conf << EOF
default_realm = ${REALM}

[kdcdefaults]
    v4_mode = nopreauth
    kdc_ports = 0

[realms]
    ${REALM} = {
        kdc_ports = 88
        admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
        database_name = /var/kerberos/krb5kdc/principal
        acl_file = /var/kerberos/krb5kdc/kadm5.acl
        key_stash_file = /var/kerberos/krb5kdc/stash
        max_life = 10h 0m 0s
        max_renewable_life = 7d 0h 0m 0s
        master_key_type = des3-hmac-sha1
        supported_enctypes = rc4-hmac:normal 
        default_principal_flags = +preauth
    }
EOF

rm -f /var/kerberos/krb5kdc/kadm5.acl
cat > /var/kerberos/krb5kdc/kadm5.acl << EOF
*/admin@${REALM}    *
cloudera-scm@${REALM}	*
EOF

kdb5_util create -r ${REALM} -s -P ${KERBEROS_PASSWORD} >> $LOG_FILE
echo -e "addprinc root/admin\n${KERBEROS_PASSWORD}\n${KERBEROS_PASSWORD}\naddprinc cloudera-scm\n${SCM_USER_PASSWORD}\n${SCM_USER_PASSWORD}\nktadd -k /var/kerberos/krb5kdc/kadm5.keytab kadmin/admin\nktadd -k /var/kerberos/krb5kdc/kadm5.keytab kadmin/changepw\nexit\n" | kadmin.local -r ${REALM}

log "-> START"
systemctl start krb5kdc.service >> $LOG_FILE
systemctl start kadmin.service >> $LOG_FILE
systemctl enable krb5kdc.service >> $LOG_FILE
systemctl enable kadmin.service >> $LOG_FILE

EXECNAME="Cloudera Manager & Pre-Reqs Install"
yum install cloudera-manager-server -y >> $LOG_FILE
yum install cloudera-manager-daemons -y >> $LOG_FILE
cp /etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/config.ini.orig
sed -e "s/\(server_host=\).*/\1${cm_fqdn}/" -i /etc/cloudera-scm-agent/config.ini
#export JDK=`ls /usr/lib/jvm | head -n 1`
#sudo JAVA_HOME=/usr/lib/jvm/$JDK/jre/ /opt/cloudera/cm-agent/bin/certmanager setup --configure-services
chown -R cloudera-scm:cloudera-scm /var/lib/cloudera-scm-agent/
systemctl start nscd.service
systemctl start cloudera-scm-agent

create_random_password()
{
  perl -le 'print map { ("a".."z", "A".."Z", 0..9)[rand 62] } 1..10'
}

EXECNAME="MySQL DB"
log "->Install"
yum install mysql-server -y
log "->Tuning"
wget https://raw.githubusercontent.com/evinck/oci-cloudera2/master/scripts/my.cnf
mv my.cnf /etc/my.cnf
log "->Start"
systemctl enable mysqld
systemctl start mysqld

log "->Bootstrap Databases"
mysql_pw=` cat /var/log/mysql/mysqld.log | grep root@localhost | gawk '{print $13}'`
echo -e "$mysql_pw" >> /etc/mysql/mysql_root.pw
mysql -u root --connect-expired-password -p${mysql_pw} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'S0m3p@ssw1234';"
mysql -u root --connect-expired-password -p${mysql_pw} -e "FLUSH PRIVILEGES;"
mysql_pw="S0m3p@ssw1234"
mysql -u root -p${mysql_pw} -e "SET GLOBAL validate_password.policy=LOW;"
mysql -u root -p${mysql_pw} -e "SET GLOBAL log_bin_trust_function_creators = 1;"
mkdir -p /etc/mysql
for DATABASE in "scm" "amon" "rman" "hue" "metastore" "sentry" "nav" "navms" "oozie" "ranger" "atlas"; do
	pw=$(create_random_password)
	if [ ${DATABASE} = "metastore" ]; then
		USER="hive"
	elif [ ${DATABASE} = "ranger" ]; then
		if [ ${ranger_enabled} = "true" ]; then
			USER="rangeradmin"
		else
			continue;
		fi
	elif [ ${DATABASE} = "atlas" ]; then 
		if [ ${atlas_enabled} = "true" ]; then
			USER="atlas"
		else
			continue
		fi
	else
		USER=${DATABASE}
	fi
	echo -e "CREATE DATABASE ${DATABASE} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" >> /etc/mysql/cloudera.sql
	echo -e "CREATE USER \'${USER}\'@'%' IDENTIFIED BY \'${pw}\';" >> /etc/mysql/cloudera.sql
	echo -e "GRANT ALL on ${DATABASE}.* to \'${USER}\'@'%';" >> /etc/mysql/cloudera.sql
        echo "${USER}:${pw}" >> /etc/mysql/mysql.pw
done;
sed -i 's/\\//g' /etc/mysql/cloudera.sql
mysql -u root -p${mysql_pw} < /etc/mysql/cloudera.sql
mysql -u root -p${mysql_pw} -e "FLUSH PRIVILEGES"

log "->SCM Prepare DB"
for user in `cat /etc/mysql/mysql.pw | gawk -F ':' '{print $1}'`; do
	log "-->${user} preparation"
	pw=`cat /etc/mysql/mysql.pw | grep -w $user | cut -d ':' -f 2`
	if [ $user = "hive" ]; then 
		database="metastore"
	elif [ $user = "rangeradmin" ]; then
		database="ranger"
	else
		database=${user}
	fi
	/opt/cloudera/cm/schema/scm_prepare_database.sh mysql ${database} ${user} ${pw}
done;
vol_match() {
case $i in
        1) disk="oraclevdb";;
        2) disk="oraclevdc";;
        3) disk="oraclevdd";;
        4) disk="oraclevde";;
        5) disk="oraclevdf";;
        6) disk="oraclevdg";;
        7) disk="oraclevdh";;
        8) disk="oraclevdi";;
        9) disk="oraclevdj";;
        10) disk="oraclevdk";;
        11) disk="oraclevdl";;
        12) disk="oraclevdm";;
        13) disk="oraclevdn";;
        14) disk="oraclevdo";;
        15) disk="oraclevdp";;
        16) disk="oraclevdq";;
        17) disk="oraclevdr";;
        18) disk="oraclevds";;
        19) disk="oraclevdt";;
        20) disk="oraclevdu";;
        21) disk="oraclevdv";;
        22) disk="oraclevdw";;
        23) disk="oraclevdx";;
        24) disk="oraclevdy";;
        25) disk="oraclevdz";;
        26) disk="oraclevdab";;
        27) disk="oraclevdac";;
        28) disk="oraclevdad";;
        29) disk="oraclevdae";;
        30) disk="oraclevdaf";;
        31) disk="oraclevdag";;
esac
}

EXECNAME="Cloudera Manager"
log "->Starting Cloudera Manager"
chown -R cloudera-scm:cloudera-scm /etc/cloudera-scm-server
systemctl start cloudera-scm-server
EXECNAME="Cloudera ${cloudera_version}"
log "->Installing Python Pre-reqs"
sudo yum install python python-pip -y >> $LOG_FILE
sudo pip install --upgrade pip >> $LOG_FILE
sudo pip install cm_client >> $LOG_FILE
log "->Running Cluster Deployment"
log "-->Host Discovery"
detection_flag="0"
w=1
while [ $detection_flag = "0" ]; do
	worker_lookup=`host cloudera-worker-$w.${cluster_subnet}.${cluster_domain}`
	worker_check=`echo -e $?`
	if [ $worker_check = "0" ]; then 
		worker_fqdn[$w]="cloudera-worker-$w.${cluster_subnet}.${cluster_domain}"
		w=$((w+1))
	else
		detection_flag="1"
	fi
done;
fqdn_list="cloudera-utility-1.${utility_subnet}.${cluster_domain},cloudera-master-1.${cluster_subnet}.${cluster_domain},cloudera-master-2.${cluster_subnet}.${cluster_domain}"
num_workers=${#worker_fqdn[@]}
for w in `seq 1 $num_workers`; do 
	fqdn_list=`echo "${fqdn_list},${worker_fqdn[$w]}"`
done;
log "-->Host List: ${fqdn_list}"
log "-->Cluster Build"
XOPTS=''
if [ ${ranger_enabled} = "true" ]; then
	XOPTS="-R ${rangeradmin_password}"
fi
if [ ${secure_cluster} = "true" ]; then 
	XOPTS="${XOPTS} -S"
fi
if [ ${hdfs_ha} = "true" ]; then
	XOPTS="${XOPTS} -H"
fi
if [ ${debug} = "true" ]; then
	XOPTS="${XOPTS} -D"
fi


wget https://raw.githubusercontent.com/evinck/oci-cloudera2/master/scripts/deploy_on_oci.py
mv deploy_on_oci.py /var/lib/cloud/instance/scripts/deploy_on_oci.py

log "---> python /var/lib/cloud/instance/scripts/deploy_on_oci.py -m ${cm_ip} -i ${fqdn_list} -d ${worker_disk_count} -w ${worker_shape} -n ${num_workers} -cdh ${cloudera_version} -N ${cluster_name} -a ${cm_username} -p ${cm_password} -v ${vcore_ratio} -C ${service_list} -M mysql -Y ${yarn_scheduler} ${XOPTS}"
python /var/lib/cloud/instance/scripts/deploy_on_oci.py -m ${cm_ip} -i ${fqdn_list} -d ${worker_disk_count} -w ${worker_shape} -n ${num_workers} -cdh ${cloudera_version} -N ${cluster_name} -a ${cm_username} -p ${cm_password} -v ${vcore_ratio} -C ${service_list} -M mysql -Y ${yarn_scheduler} ${XOPTS} 2>&1 >> $LOG_FILE	
log "->DONE"
