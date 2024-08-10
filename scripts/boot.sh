#!/bin/bash

LOG_FILE="/var/log/cloudera-OCI-initialize.log"
log() { 
	echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}" 
}

cm_fqdn=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cloudera_manager`
fqdn_fields=`echo -e $cm_fqdn | gawk -F '.' '{print NF}'`
cluster_domain=`echo -e $cm_fqdn | cut -d '.' -f 3-${fqdn_fields}`
cloudera_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cloudera_version`
cloudera_major_version=`echo $cloudera_version | cut -d '.' -f1`
cm_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cm_version`
cm_major_version=`echo  $cm_version | cut -d '.' -f1`
block_volume_count=`curl -L http://169.254.169.254/opc/v1/instance/metadata/block_volume_count`
objectstoreRAID=`curl -L http://169.254.169.254/opc/v1/instance/metadata/objectstoreRAID`
if [ $objectstoreRAID = "true" ]; then 
	block_volume_count=$((block_volume_count+4))
fi
enable_secondary_vnic=`curl -L http://169.254.169.254/opc/v1/instance/metadata/enable_secondary_vnic`
if [ $enable_secondary_vnic = "true" ]; then
        EXECNAME="SECONDARY VNIC"
	host_shape=` curl -L http://169.254.169.254/opc/v1/instance/shape`
	case ${host_shape} in 
		BM.HPC2.36)
		log "-> Skipping setup, RDMA setup not implemented"
		;;

		*) 
	        log "->Download setup script"
	        wget https://docs.cloud.oracle.com/en-us/iaas/Content/Resources/Assets/secondary_vnic_all_configure.sh
	        mkdir -p /opt/oci/
		mv secondary_vnic_all_configure.sh /opt/oci/
		chmod +x /opt/oci/secondary_vnic_all_configure.sh
	        log "->Configure"
	        /opt/oci/secondary_vnic_all_configure.sh -c >> $LOG_FILE
	        log "->rc.local enable"
	        echo "/opt/oci/secondary_vnic_all_configure.sh -c" >> /etc/rc.local
		;;
	esac
fi

EXECNAME="TUNING"
log "->TUNING START"
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
EXECNAME="PAUSE FOR YUM"
log "->Waiting 120 seconds to ensure YUM is ready to go"
sleep 120
EXECNAME="JAVA"
log "->INSTALL"
yum install java-1.8.0-openjdk.x86_64 -y >> $LOG_FILE
EXECNAME="NSCD"
log "->INSTALL"
yum install nscd -y >> $LOG_FILE
systemctl start nscd.service

EXECNAME="KERBEROS"
log "->INSTALL"
yum install krb5-workstation -y >> $LOG_FILE
log "->krb5.conf"
kdc_fqdn=${cm_fqdn}
realm="hadoop.com"
REALM="HADOOP.COM"
log "-> CONFIG"
rm -f /etc/krb5.conf
cat > /etc/krb5.conf << EOF
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[libdefaults]
 default_realm = ${REALM}
 dns_lookup_realm = false
 dns_lookup_kdc = false
 rdns = false
 ticket_lifetime = 24h
 renew_lifetime = 7d  
 forwardable = true
 udp_preference_limit = 1000000
 default_tkt_enctypes = rc4-hmac 
 default_tgs_enctypes = rc4-hmac
 permitted_enctypes = rc4-hmac

[realms]
    ${REALM} = {
        kdc = ${kdc_fqdn}:88
        admin_server = ${kdc_fqdn}:749
        default_domain = ${realm}
    }

[domain_realm]
    .${realm} = ${REALM}
     ${realm} = ${REALM}
    bastion1.${cluster_domain} = ${REALM}
    .bastion1.${cluster_domain} = ${REALM}
    bastion2.${cluster_domain} = ${REALM}
    .bastion2.${cluster_domain} = ${REALM}
    bastion3.${cluster_domain} = ${REALM}
    .bastion3.${cluster_domain} = ${REALM}
    .public1.${cluster_domain} = ${REALM}
    public1.${cluster_domain} = ${REALM}
    .public2.${cluster_domain} = ${REALM}
    public2.${cluster_domain} = ${REALM}
    .public3.${cluster_domain} = ${REALM}
    public3.${cluster_domain} = ${REALM}
    .private1.${cluster_domain} = ${REALM}
    private1.${cluster_domain} = ${REALM}
    .private2.${cluster_domain} = ${REALM}
    private2.${cluster_domain} = ${REALM}
    .private3.${cluster_domain} = ${REALM}
    private3.${cluster_domain} = ${REALM}

[kdc]
    profile = /var/kerberos/krb5kdc/kdc.conf

[logging]
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmin.log
    default = FILE:/var/log/krb5lib.log
EOF

EXECNAME="TUNING"
log "->OS"
# echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled
echo never | tee -a /sys/kernel/mm/transparent_hugepage/defrag
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled" | tee -a /etc/rc.local
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/defrag" | tee -a /etc/rc.local
echo vm.swappiness=1 | tee -a /etc/sysctl.conf
echo 1 | tee /proc/sys/vm/swappiness
echo net.ipv4.tcp_timestamps=0 >> /etc/sysctl.conf
echo net.ipv4.tcp_sack=1 >> /etc/sysctl.conf
echo net.core.rmem_max=4194304 >> /etc/sysctl.conf
echo net.core.wmem_max=4194304 >> /etc/sysctl.conf
echo net.core.rmem_default=4194304 >> /etc/sysctl.conf
echo net.core.wmem_default=4194304 >> /etc/sysctl.conf
echo net.core.optmem_max=4194304 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem="4096 87380 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem="4096 65536 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_low_latency=1 >> /etc/sysctl.conf
sed -i "s/defaults        1 1/defaults,noatime        0 0/" /etc/fstab
echo "hdfs  -       nofile  32768
hdfs  -       nproc   2048
hbase -       nofile  32768
hbase -       nproc   2048" >> /etc/security/limits.conf
ulimit -n 262144
log "->FirewallD"
systemctl stop firewalld
systemctl disable firewalld

EXECNAME="MYSQL Connector"
log "->INSTALL"
export MYSQL_PKG="mysql-connector-j-8.4.0-1.el8.noarch.rpm"
wget https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_PKG}
# tar zxvf ${MYSQL_PKG}
# mkdir -p /usr/share/java/
# cd mysql-connector-java-5.1.46
# cp mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar
yum install *.rpm -y


# Disk Setup Functions
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
iscsi_detection() {
	iscsiadm -m discoverydb -D -t sendtargets -p 169.254.2.$i:3260 2>&1 2>/dev/null
	iscsi_chk=`echo -e $?`
	if [ $iscsi_chk = "0" ]; then
		iqn[${i}]=`iscsiadm -m discoverydb -D -t sendtargets -p 169.254.2.${i}:3260 | gawk '{print $2}'`
		log "-> Discovered volume $((i-1)) - IQN: ${iqn[${i}]}"
		continue
	else
		volume_count="${#iqn[@]}"
		log "--> Discovery Complete - ${#iqn[@]} volumes found"
	fi
}
iscsi_setup() {
        log "-> ISCSI Volume Setup - Volume ${i} : IQN ${iqn[$n]}"
        iscsiadm -m node -o new -T ${iqn[$n]} -p 169.254.2.${n}:3260
        log "--> Volume ${iqn[$n]} added"
        iscsiadm -m node -o update -T ${iqn[$n]} -n node.startup -v automatic
        log "--> Volume ${iqn[$n]} startup set"
        iscsiadm -m node -T ${iqn[$n]} -p 169.254.2.${n}:3260 -l
        log "--> Volume ${iqn[$n]} done"
}

EXECNAME="DISK DETECTION"
log "->Begin Block Volume Detection Loop"
detection_flag="0"
while [ "$detection_flag" = "0" ]; do
        log "-- Detecting Block Volumes --"
        for i in `seq 2 33`; do
                if [ -z $volume_count ]; then
			iscsi_detection
		fi
        done;

        master_check=`hostname | grep -c master`
        bastion_check=`hostname | grep -c bastion`
        utility_check=`hostname | grep -c utility`

        if [ $master_check = "1" ]; then
                total_volume_count=3
        elif [ $bastion_check = "1" ]; then
                total_volume_count=2
        elif [ $utility_check = "1" ]; then
                total_volume_count=2
        else
                total_volume_count=$((block_volume_count+2))
        fi

	log "-- $total_volume_count volumes expected $volume_count volumes found --"
        if [ "$volume_count" = "0" ]; then
                log "-- $volume_count Block Volumes detected, sleeping 15 then retry --"
		unset volume_count
		unset iqn
                sleep 15
                continue
        elif [ "$volume_count" != "$total_volume_count" ]; then
                log "-- Sanity Check Failed - $volume_count Volumes found, $total_volume_count expected.  Re-running --"
		unset volume_count
		unset iqn
                sleep 15
                continue
	else
                log "-- Setup for ${#iqn[@]} Block Volumes --"
                for i in `seq 1 ${#iqn[@]}`; do
                        n=$((i+1))
                        iscsi_setup
                done;
                detection_flag="1"
        fi
done;

EXECNAME="DISK PROVISIONING"
data_mount () {
  log "-->Mounting /dev/$disk to /data$dcount"
  mkdir -p /data$dcount
  mount -o noatime,barrier=1 -t ext4 /dev/$disk /data$dcount
  UUID=`blkid /dev/$disk | cut -d '"' -f2`
  echo "UUID=$UUID   /data$dcount    ext4   defaults,noatime,discard,barrier=0 0 1" | tee -a /etc/fstab
}

block_data_mount () {
  log "-->Mounting /dev/oracleoci/$disk to /data$dcount"
  mkdir -p /data$dcount
  mount -o noatime,barrier=1 -t ext4 /dev/oracleoci/$disk /data$dcount
  UUID=`blkid /dev/oracleoci/$disk | cut -d '"' -f 2`
  if [ ! -z $UUID ]; then 
  	echo "UUID=$UUID   /data$dcount    ext4   defaults,_netdev,nofail,noatime,discard,barrier=0 0 2" | tee -a /etc/fstab
  fi
}

raid_disk_setup() {
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/oracleoci/$disk
n
p
1


t
fd
w
EOF
}

EXECNAME="DISK SETUP"
log "->Checking for disks..."
dcount=0
for disk in `ls /dev/ | grep nvme | grep n1`; do
        log "-->Processing /dev/$disk"
        mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 /dev/$disk
        data_mount
        dcount=$((dcount+1))
done;
if [ ${#iqn[@]} -gt 0 ]; then
for i in `seq 1 ${#iqn[@]}`; do
        n=$((i+1))
        dsetup="0"
        while [ $dsetup = "0" ]; do
                vol_match
                log "-->Checking /dev/oracleoci/$disk"
                if [ -h /dev/oracleoci/$disk ]; then
                        case $disk in
                                oraclevdb)
                                mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 /dev/oracleoci/$disk
                                log "--->Mounting /dev/oracleoci/$disk to /var/log/cloudera"
                                mkdir -p /var/log/cloudera
                                mount -o noatime,barrier=1 -t ext4 /dev/oracleoci/$disk /var/log/cloudera
	                        echo "/dev/oracleoci/oraclevdb   /var/log/cloudera    ext4   defaults,_netdev,nofail,noatime,discard,barrier=0 0 2" | tee -a /etc/fstab
                                mkdir -p /var/log/cloudera/cloudera-scm-agent
                                ln -s /var/log/cloudera/cloudera-scm-agent /var/log/cloudera-scm-agent
                                ;;
                                oraclevdc)
                                mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 /dev/oracleoci/$disk
                                log "--->Mounting /dev/oracleoci/$disk to /opt/cloudera"
                                mkdir -p /opt/cloudera
                                mount -o noatime,barrier=1 -t ext4 /dev/oracleoci/$disk /opt/cloudera
	                        echo "/dev/oracleoci/oraclevdc   /opt/cloudera    ext4   defaults,_netdev,nofail,noatime,discard,barrier=0 0 2" | tee -a /etc/fstab
                                ;;
				oraclevdd|oraclevde|oraclevdf|oraclevdg)
				if [ $objectstoreRAID = "true" ]; then 
					raid_disk_setup
				else
	                                mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 /dev/oracleoci/$disk
	                                block_data_mount
        	                        dcount=$((dcount+1))
				fi
                                ;;
                                *)
                                mke2fs -F -t ext4 -b 4096 -E lazy_itable_init=1 -O sparse_super,dir_index,extent,has_journal,uninit_bg -m1 /dev/oracleoci/$disk
                                block_data_mount
                                dcount=$((dcount+1))
                                ;;
                        esac
                        /sbin/tune2fs -i0 -c0 /dev/oracleoci/$disk
			unset UUID
                        dsetup="1"
                else
                        log "--->${disk} not found, running ISCSI again."
                        log "-- Re-Running Detection & Setup Block Volumes --"
			detection_done="0"
			log "-- Detecting Block Volumes --"
			for i in `seq 2 33`; do
				if [ $detection_done = "0" ]; then
		                        iscsi_detection
                		fi
		        done;
			for j in `seq 1 ${#iqn[@]}`; do
				n=$((j+1))
	                        iscsi_setup
			done
                fi
        done;
done;
fi
if [ $objectstoreRAID = "true" ]; then 
	EXECNAME="TMP"
	log "->Setup LVM"
	vgcreate RAID0 /dev/oracleoci/oraclevd[d-g]1
	lvcreate -i 2 -I 64 -l 100%FREE -n tmp RAID0
	mkfs.ext4 /dev/RAID0/tmp
	mkdir -p /mnt/tmp
	chmod 1777 /mnt/tmp
	mount /dev/RAID0/tmp /mnt/tmp
	mount -B /tmp /mnt/tmp
	chmod 1777 /tmp
	echo "/dev/RAID0/tmp                /tmp              ext4    defaults,_netdev,noatime,discard,barrier=0         0 0" | tee -a /etc/fstab
fi

EXECNAME="Python 3.8 installation"
yum remove python3 -y >> $LOG_FILE
yum install python3.8 -y >> $LOG_FILE

EXECNAME="Cloudera Agent Install"
# if [ ${cm_major_version} = "7" ]; then
#        log "-->CDP install detected - CM $cm_version"
#       rpm --import https://archive.cloudera.com/cm${cm_major_version}/${cm_version}/redhat7/yum/RPM-GPG-KEY-cloudera
#       wget https://archive.cloudera.com/cm${cm_major_version}/${cm_version}/redhat7/yum/cloudera-manager-trial.repo -O /etc/yum.repos.d/cloudera-manager.repo
# else
#        log "-->Setup GPG Key & CM ${cm_version} repo"
#        rpm --import https://archive.cloudera.com/cm${cm_major_version}/${cm_version}/redhat7/yum/RPM-GPG-KEY-cloudera
#        wget http://archive.cloudera.com/cm${cm_major_version}/${cm_version}/redhat7/yum/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo
#fi

wget https://d753ce7b-f010-4314-b074-1de8bc5a105f:618bf3e66162@archive.cloudera.com/p/cm7/7.11/redhat8/yum/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo

yum install cloudera-manager-agent -y >> $LOG_FILE
export JDK=`ls /usr/lib/jvm | head -n 1`
sudo JAVA_HOME=/usr/lib/jvm/$JDK/jre/ /opt/cloudera/cm-agent/bin/certmanager setup --configure-services
cp /etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/config.ini.orig
sed -e "s/\(server_host=\).*/\1${cm_fqdn}/" -i /etc/cloudera-scm-agent/config.ini
sed -e "s/use_tls=0/use_tls=1/" -i /etc/cloudera-scm-agent/config.ini

if [ ${enable_secondary_vnic} = "true" ]; then 
	agent_hostname=`curl -L http://169.254.169.254/opc/v1/instance/metadata/agent_hostname`
	sed -i 's,# listening_hostname=,'"listening_hostname=${agent_hostname}"',g' /etc/cloudera-scm-agent/config.ini
	agent_ip=`host ${agent_hostname} | gawk '{print $4}'`
	sed -i 's,# listening_ip=,'"listening_ip=${agent_ip}"',g' /etc/cloudera-scm-agent/config.ini
fi
systemctl start cloudera-scm-agent
EXECNAME="END"
log "->DONE"
