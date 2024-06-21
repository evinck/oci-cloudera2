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

// See https://docs.oracle.com/en-us/iaas/images/image/de69cf4f-8f5f-4646-8529-2a8b80bb3264/
// Updated by eric.vinck@oracle.com on 12/06/24
// Oracle-Linux-8.9-2024.05.29-0
// 


variable "OELImageOCID" {
  type = map
  default = {
    af-johannesburg-1="ocid1.image.oc1.af-johannesburg-1.aaaaaaaa2pvudoe4rlrngal47t7ve3x5iqovqwfd6fruho5ejpuf7c4azgna"
    ap-chuncheon-1="ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaunwekj6f6c2tr3wjeo6krst6mvoziywdfxtl5ibp7bekcgxcq5ea"
    ap-hyderabad-1="ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaslydatemd5ndwrvt2zgrrpmcqsde5ly53ew7r7nqonpe2czzy5cq"
    ap-melbourne-1="ocid1.image.oc1.ap-melbourne-1.aaaaaaaaxyjmocuvdzewjqn3vqw2xo4hlmrjgvdg2mgwkj7vsiedxm7yk25a"
    ap-mumbai-1="ocid1.image.oc1.ap-mumbai-1.aaaaaaaaka5tzaglhspdu72do7l5ffu6wkdaaa7ckmw4wfqverygjzgeq3xa"
    ap-osaka-1="ocid1.image.oc1.ap-osaka-1.aaaaaaaamx4xwoxwkbud2s7ezrbe5hio7dgt7phpcruqcu66omf3ac7at6lq"
    ap-seoul-1="ocid1.image.oc1.ap-seoul-1.aaaaaaaaow2nrto4fmtyo6all6twcr2wwjcim2qhguiipymbimmfxe773nyq"
    ap-singapore-1="ocid1.image.oc1.ap-singapore-1.aaaaaaaa3rpavlitpbixnrwfvw7z7t6dqyqxilftzow56kritfryvx7iok4a"
    ap-sydney-1="ocid1.image.oc1.ap-sydney-1.aaaaaaaabnxikcccwfimzid4xvtnrmbovpyujson2ybk4cq2quprenot4yva"
    ap-tokyo-1="ocid1.image.oc1.ap-tokyo-1.aaaaaaaa2vfxs5eqzyk4o7lyd6j4bo42pfy6oqrwfzkkho54uwiafy7nxu3a"
    ca-montreal-1="ocid1.image.oc1.ca-montreal-1.aaaaaaaaf4gixkomhel5bsiadj523xaaupq7qli47prfoeu3sv4zskvb3yma"
    ca-toronto-1="ocid1.image.oc1.ca-toronto-1.aaaaaaaaeonnf55icwpffvzbzfgva7fkf5mrnd7f53ope255vjmpbufcqlna"
    eu-amsterdam-1="ocid1.image.oc1.eu-amsterdam-1.aaaaaaaazhi2nufvejut7shs7ap6cd6nt4j3ysuknrzkqo7uywz5wl2gspoa"
    eu-frankfurt-1="ocid1.image.oc1.eu-frankfurt-1.aaaaaaaai5ywzhffasoujxtn3gvv27x2cdr2lbxds6ri5tyxt36p4bh3deza"
    eu-madrid-1="ocid1.image.oc1.eu-madrid-1.aaaaaaaaobc3xqy2adojbk2ffb72lzdnmsxk7uzkxeuj52rshuynbhx6ukqq"
    eu-marseille-1="ocid1.image.oc1.eu-marseille-1.aaaaaaaaq2efe43c7lj63iatvyhr2ou5wnyclioc5zmbxgqmeaf35z6av65a"
    eu-milan-1="ocid1.image.oc1.eu-milan-1.aaaaaaaa2qft2bvi5plpwsudc56tjt4zqr54mppwa2t3d5jhq22j6q6s3w7a"
    eu-paris-1="ocid1.image.oc1.eu-paris-1.aaaaaaaakhu6ttzzalexl4jp2is7k7pykhlv4wr6ba6esadlyliw36cul2nq"
    eu-stockholm-1="ocid1.image.oc1.eu-stockholm-1.aaaaaaaaibvfnx6fsvph7nbunf6fx6nvp2vifjuxf7nsh4ztmyvvghqzq76q"
    eu-zurich-1="ocid1.image.oc1.eu-zurich-1.aaaaaaaaxzlvcsxsjvn7myqclu7fggptsjn5rujnwn75sxwqbns22yesy2wa"
    il-jerusalem-1="ocid1.image.oc1.il-jerusalem-1.aaaaaaaaq24s4hi6osp6q6xouovseejzqnk6mpmjx3s6adwek3fkagyf4v3a"
    me-abudhabi-1="ocid1.image.oc1.me-abudhabi-1.aaaaaaaa3nr6taeqg6hbu6fqwekl2javmm74gtcnotn3yb4mecwy2pyoxfgq"
    me-dubai-1="ocid1.image.oc1.me-dubai-1.aaaaaaaaptpdkp4rkyfwgqraeodzgiw7scwllnbo543jlaqxcdald6gxgkwq"
    me-jeddah-1="ocid1.image.oc1.me-jeddah-1.aaaaaaaaffwt75p4xicynzt4utrhkvutwxlhackhpqygaxlque2rsss6lqda"
    mx-monterrey-1="ocid1.image.oc1.mx-monterrey-1.aaaaaaaammip4uekuqcbqbfdtw5ys4tc5f275ilj76syo3oki64fnigfxi6a"
    mx-queretaro-1="ocid1.image.oc1.mx-queretaro-1.aaaaaaaae3rjhb5h46j3s46e3d6dfsf2xpw6n6akcp3kjmahy4dnjwnfbnua"
    sa-bogota-1="ocid1.image.oc1.sa-bogota-1.aaaaaaaasora2w7jtqq7yipa7vo3b6pihnbfz2hqpwtpxjxigjhphevv7bsq"
    sa-santiago-1="ocid1.image.oc1.sa-santiago-1.aaaaaaaa2tl3iz7b356efjpcuqlauw62pgp3vprx24okgkj6ktwxkh7svxca"
    sa-saopaulo-1="ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaxkrwo2fm3qy3jtw4k6k2rsf5frjsfc4es6mr4dejtuerrg3opn7a"
    sa-valparaiso-1="ocid1.image.oc1.sa-valparaiso-1.aaaaaaaanmday4xpcn2wilcngtuwwwblxhnzol5fg3av4bi2fj6jxej2zyxa"
    sa-vinhedo-1="ocid1.image.oc1.sa-vinhedo-1.aaaaaaaaooelsxmjbyzum3yxnate7oova2x7gptrerzhqmd5zmmbrj5znhtq"
    uk-cardiff-1="ocid1.image.oc1.uk-cardiff-1.aaaaaaaaec3muh4gxhddcurmkuggbpxcxn57cfrungbxy6heg42wd6aqkkxq"
    uk-london-1="ocid1.image.oc1.uk-london-1.aaaaaaaaebhu66xkmserrvecfa4cvxcfwkis7o5obbwlt46gfxuwsne6rjya"
    us-ashburn-1="ocid1.image.oc1.iad.aaaaaaaaxtzkhdlxbktlkhiausqz7qvqg7d5jqbrgy6empmrojtdktwfv7fq"
    us-chicago-1="ocid1.image.oc1.us-chicago-1.aaaaaaaa7fax5zz4ijmef3za2gm2eg4relmg24nad6xryvm7d6t5q2qfl4uq"
    us-phoenix-1="ocid1.image.oc1.phx.aaaaaaaaautoznfvfzx45j2ittldxjkcf63ss4ovaptpvxh3ixwd4lfisevq"
    us-sanjose-1="ocid1.image.oc1.us-sanjose-1.aaaaaaaaiuohacxlmjoy27czv3bgshoxqlsgags53s3vqyl5z4rnpbge6z7a"
  }
}

