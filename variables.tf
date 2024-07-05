# ---------------------------------------------------------------------------------------------------------------------
# SSH Keys - Put this to top level because they are required
# ---------------------------------------------------------------------------------------------------------------------

variable "ssh_provided_key" {
  default = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Settings
# --------------------------------------------------------------------------------------------------------------------- 
variable "useExistingVcn" {
  default = "false"
}

variable "hide_public_subnet" {
  default = "true"
}

variable "hide_private_subnet" {
  default = "true"
}

variable "custom_cidrs" {
  default = "false"
}

variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}

variable "edge_cidr" {
  default = "10.0.1.0/24"
}

variable "public_cidr" {
  default = "10.0.2.0/24"
}

variable "private_cidr" {
  default = "10.0.3.0/24"
}

variable "blockvolume_cidr" {
  default = "10.0.4.0/24"
}

variable "myVcn" {
  default = " "
}

variable "clusterSubnet" {
  default = " "
}

variable "bastionSubnet" {
  default = " "
}

variable "utilitySubnet" {
  default = " "
}

variable "blockvolumeSubnet" {
  default = " "
}

variable "vcn_dns_label" { 
  default = "clouderavcn"
}

variable "secondary_vnic_count" {
  default = "0"
}

variable "blockvolume_subnet_id" {
  default = " "
}

variable "worker_domain" {
  default = " "
}

# ---------------------------------------------------------------------------------------------------------------------
# ORM Schema variables
# You should modify these based on deployment requirements.
# These default to recommended values
# --------------------------------------------------------------------------------------------------------------------- 

variable "meta_db_type" {
  default = "mysql"
}

variable "use_edge_nodes" {
  default = "false"
}

variable "enable_block_volumes" {
  default = "true"
}

variable "cm_username" {
  default = "cm_admin"
}

variable "cm_password" {
   default = "changeme"
}

variable "provide_ssh_key" {
  default = "true"
}

variable "vcore_ratio" {
  default = "2"
}

variable "yarn_scheduler" {
  default = "capacity"
}

variable "enable_secondary_vnic" {
  default = "false"
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloudera variables
# You should modify these based on deployment requirements.
# These default to recommended minimum values in most cases
# ---------------------------------------------------------------------------------------------------------------------

# Cloudera Manager Version
variable "cm_version" { 
    default = "7.11.13" 
}
# Cloudera Enterprise Data Hub Version
variable "cloudera_version" { 
    default = "7.1.9" 
}
variable "secure_cluster" { 
    default = "True" 
}

variable "hdfs_ha" {
    default = "False"
}

variable "worker_instance_shape" {
  default = "VM.Standard2.16"
}

variable "worker_instance_ocpus" {
  default = "2"
}

variable "worker_instance_mem" {
  default = "32"
}

variable "worker_node_count" {
  default = "5"
}

variable "data_blocksize_in_gbs" {
  default = "700"
}

variable "block_volumes_per_worker" {
   default = "3"
}

variable "customize_block_volume_performance" {
   default = "false"
}

variable "block_volume_high_performance" {
   default = "false"
}

variable "block_volume_cost_savings" {
   default = "false"
}

variable "vpus_per_gb" {
   default = "10"
}

variable "utility_instance_shape" {
  default = "VM.Standard2.8"
}

variable "utility_instance_ocpus" {
  default = "2"
}

variable "utility_instance_mem" {
  default = "32"
}

variable "master_instance_shape" {
  default = "VM.Standard2.8"
}

variable "master_instance_ocpus" {
  default = "2"
}

variable "master_instance_mem" {
  default = "32"
}

variable "master_node_count" {
  default = "2"
}

# Size for Cloudera Log Volumes across all hosts deployed to /var/log/cloudera

variable "log_volume_size_in_gbs" {
  default = "200"
}

# Size for Volume across all hosts deployed to /opt/cloudera

variable "cloudera_volume_size_in_gbs" {
  default = "300"
}

# Size for NameNode and SecondaryNameNode data volume (Journal Data)

variable "nn_volume_size_in_gbs" {
  default = "500"
}

variable "bastion_instance_shape" {
  default = "VM.Standard2.4"
}

variable "bastion_instance_ocpus" {
  default = "2"
}

variable "bastion_instance_mem" {
  default = "32"
}

variable "bastion_node_count" {
  default = "1"
}

# Which AD to target - this can be adjusted.  Default 1 for single AD regions.
variable "availability_domain" {
  default = "1"
}

variable "cluster_name" {
  default = "TestCluster"
}

variable "objectstoreRAID" {
  default = "false" 
}

variable "AdvancedOptions" {
  default = "false"
}

variable "svc_ATLAS" { 
  default = "false"
}

variable "svc_HBASE" {
  default = "true"
}

variable "svc_HDFS" {
  default = "true"
}

variable "svc_HIVE" {
  default = "true" 
}

variable "svc_IMPALA" {
  default = "true" 
}

variable "svc_KAFKA" {
  default = "true"
}

variable "svc_OOZIE" {
  default = "true" 
}

variable "svc_RANGER" {
  default = "false"
}

variable "svc_SOLR" {
  default = "true" 
}

variable "svc_SPARK_ON_YARN" {
  default = "true"
}

variable "svc_SQOOP_CLIENT" {
  default = "true"
}

variable "svc_YARN" {
  default = "true"
}

variable "rangeradmin_password" {
  default = "Test123!"
}

variable "enable_debug" {
  default = "false"
}
# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oracle/oci-quickstart-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "compartment_ocid" {}

# Required by the OCI Provider

variable "tenancy_ocid" {}
variable "region" {}

# ---------------------------------------------------------------------------------------------------------------------
# Constants
# You probably don't need to change these.
# ---------------------------------------------------------------------------------------------------------------------


// Updated by eric.vinck@oracle.com on 12/06/24
// check compatibility matrix for cdp https://supportmatrix.cloudera.com/
// Oracle-Linux-8.8-2023.12.13-0
// https://docs.oracle.com/en-us/iaas/images/image/df917215-9572-4eb5-948b-c4e2fe1be4f5/


variable "OELImageOCID" {
  type = map
  default = {
    af-johannesburg-1="ocid1.image.oc1.af-johannesburg-1.aaaaaaaavvwcdzy7e2pirf7ogf2aodrufdtswebkdmbrp44pdplv5xpo3vra"
    ap-chuncheon-1="ocid1.image.oc1.ap-chuncheon-1.aaaaaaaangiiuij5sptq6sj7hmomnrwhaevmm4ypuydvq3fa5p7tyrp2mtwq"
    ap-hyderabad-1="ocid1.image.oc1.ap-hyderabad-1.aaaaaaaasjbh7fw4gf5o5xd6flspaxthprhwvhbwzsv76oghbxkc4htg6usq"
    ap-melbourne-1="ocid1.image.oc1.ap-melbourne-1.aaaaaaaab5xa3x27wen5o3t7da4xyt4r6cyvpi33acz6izdjjsu7so3pvofq"
    ap-mumbai-1="ocid1.image.oc1.ap-mumbai-1.aaaaaaaanegvgst5wzdeb7r2qgwqugxgwau6txxekheu3k2xpujpiwxsoioq"
    ap-osaka-1="ocid1.image.oc1.ap-osaka-1.aaaaaaaaxkgpvrihstrml2e7hy7yvmozu3p3j4ossbbd77lehpuvivjvfciq"
    ap-seoul-1="ocid1.image.oc1.ap-seoul-1.aaaaaaaa72qfkpqpiheaykom3axf735fpoecnunsvnl6uclnif4dfgruq2da"
    ap-singapore-1="ocid1.image.oc1.ap-singapore-1.aaaaaaaahelel2d5qmnvgwxiccesb2atb4xsaebmn4a3fiyrtv5sbfnvqqrq"
    ap-sydney-1="ocid1.image.oc1.ap-sydney-1.aaaaaaaavaduzfdla47ukwgoleaefc26ds6olprsl7d2xmfjybjet5k2dxta"
    ap-tokyo-1="ocid1.image.oc1.ap-tokyo-1.aaaaaaaa4etzu57mque5ma3zcrhisizuhzyp7e43zlzmar35wt3f4mymyjoq"
    ca-montreal-1="ocid1.image.oc1.ca-montreal-1.aaaaaaaa7anl4r3wzthov6skp77c6g4iyedkjokppaiualx7o5p4go7nuswq"
    ca-toronto-1="ocid1.image.oc1.ca-toronto-1.aaaaaaaaxo5uchzon7glxm5bvdffpkoser7ylc74lpkbso777lyebl37b4ka"
    eu-amsterdam-1="ocid1.image.oc1.eu-amsterdam-1.aaaaaaaafevkkjsicpzlfkag4spj2xl5rcfysfz6xt5o46zjcidf3rc2mrfq"
    eu-frankfurt-1="ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaqzszsmyx5ue5qnzkzwrps6crl6os473iuf5tmz5z47bfxksnilya"
    eu-madrid-1="ocid1.image.oc1.eu-madrid-1.aaaaaaaahfnlqr3m35ecjvu77acor7osnuiurgbrhy4ihq5nxlw3ntguom5a"
    eu-marseille-1="ocid1.image.oc1.eu-marseille-1.aaaaaaaaihfzzxbo4khrcaala2gwqrwcqpabkwmrj64p5whntzvqlgf5uz7a"
    eu-milan-1="ocid1.image.oc1.eu-milan-1.aaaaaaaa6dymjhuaj2kox5h5owejoqjooptqmlgc5frq777wi3b77e7smqea"
    eu-paris-1="ocid1.image.oc1.eu-paris-1.aaaaaaaa73yqsdqeugj4vc3rwhsugnp2iravedo3rn7zstiouvnvwb4ottyq"
    eu-stockholm-1="ocid1.image.oc1.eu-stockholm-1.aaaaaaaae3cp2o2hbqakvn6xf3kz5v7v6276o5gdgx6ry35n6lnafpd2wyya"
    eu-zurich-1="ocid1.image.oc1.eu-zurich-1.aaaaaaaahd36gjlhlrvzzkjmzcfsp6e4zxzyhxxthwofr6f5ndwujn6r6ucq"
    il-jerusalem-1="ocid1.image.oc1.il-jerusalem-1.aaaaaaaaiks6flck2t4e6neogl2ncutylrivya62ebcrhi2ztlkax74eyqdq"
    me-abudhabi-1="ocid1.image.oc1.me-abudhabi-1.aaaaaaaai5hunaeb77qnyve7vverljggpdxxswais6tplqmymo4b62cxcboa"
    me-dubai-1="ocid1.image.oc1.me-dubai-1.aaaaaaaa2n7huqgv5mrepi3ilzrf5l3wx3qxenlfhb2xcwzs5cnxxc74jseq"
    me-jeddah-1="ocid1.image.oc1.me-jeddah-1.aaaaaaaaif4t32bvvw5jnp3l5pamta6usk3eodpgsaybonugm4lh773nhhoq"
    mx-queretaro-1="ocid1.image.oc1.mx-queretaro-1.aaaaaaaayqyocu3o6xsbso37q7yxbcrx7mph5txawwgx4giguyyjdynnphfq"
    sa-santiago-1="ocid1.image.oc1.sa-santiago-1.aaaaaaaaw3wuswxzgvls2mtyjt4pog2xueiovjujwt23zkq5m3axuuawwxpa"
    sa-saopaulo-1="ocid1.image.oc1.sa-saopaulo-1.aaaaaaaac55wdf4uqhb3ybs3fgwwirhhu3k5a45kbe3xundigck767ad7pdq"
    sa-vinhedo-1="ocid1.image.oc1.sa-vinhedo-1.aaaaaaaaemne73c2bzfcvbrnw2zp5xsqytugjs6x4347jclta52cuuyytqwa"
    uk-cardiff-1="ocid1.image.oc1.uk-cardiff-1.aaaaaaaayf42e2q5rcoemx54chinqor4hrytkyf65i76m6uvpfk6iy446ksa"
    uk-london-1="ocid1.image.oc1.uk-london-1.aaaaaaaa4ijmnmoupcixncuuwlx7oqalzgbmrlyzdewn22fibel42lefgeqa"
    us-ashburn-1="ocid1.image.oc1.iad.aaaaaaaazi34xyxv6og7qgn3nqvaykfvg5ntkkx7yhlkjzpn4z45l72l53wa"
    us-chicago-1="ocid1.image.oc1.us-chicago-1.aaaaaaaa3ghszndlwkvnbi3632dvfumgdvswmdihgpt5ksldir6fucn6px5q"
    us-phoenix-1="ocid1.image.oc1.phx.aaaaaaaa6tymp4xfigkaqazfi6yohpljyeyum5nmijrhktkqxypt34ouwf6q"
    us-sanjose-1="ocid1.image.oc1.us-sanjose-1.aaaaaaaalxoke7w7h2vsb5mvaf4innpsieb5xdplixjtix45eznvdbm7snjq"
  }
}