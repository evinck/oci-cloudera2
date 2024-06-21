resource "oci_core_instance" "Utility" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  shape               = "${var.utility_instance_shape}"
  shape_config {
    ocpus = "${var.utility_instance_ocpus}"
    memory_in_gbs = "${var.utility_instance_mem}"
  }
  display_name        = "Cloudera Utility-1"
  fault_domain	      = "FAULT-DOMAIN-3"

  source_details {
    source_type             = "image"
    source_id               = "${var.image_ocid}"
  }

  create_vnic_details {
    subnet_id         = "${var.subnet_id}"
    display_name      = "Cloudera Utility-1"
    hostname_label    = "Cloudera-Utility-1"
    assign_public_ip  = "${var.hide_private_subnet ? true : false}"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data		= "${var.user_data}" 
  }

  extended_metadata = {
    meta_db_type	= "${var.meta_db_type}"
    cloudera_manager    = "${var.cloudera_manager}"
    cloudera_version    = "${var.cloudera_version}"
    cm_version          = "${var.cm_version}"
    worker_shape        = "${var.worker_shape}"
    block_volume_count  = "${var.block_volume_count}"
    secure_cluster      = "${var.secure_cluster}"
    hdfs_ha             = "${var.hdfs_ha}"
    cluster_name        = "${var.cluster_name}"
    cluster_subnet      = "${var.cluster_subnet}"
    bastion_subnet      = "${var.bastion_subnet}"
    utility_subnet      = "${var.utility_subnet}"
    cm_username         = "${var.cm_username}"
    cm_password         = "${var.cm_password}"
    vcore_ratio         = "${var.vcore_ratio}"
    svc_ATLAS           = "${var.svc_ATLAS}"
    svc_HBASE           = "${var.svc_HBASE}"
    svc_HDFS            = "${var.svc_HDFS}"
    svc_HIVE            = "${var.svc_HIVE}"
    svc_IMPALA          = "${var.svc_IMPALA}"
    svc_KAFKA           = "${var.svc_KAFKA}"
    svc_OOZIE           = "${var.svc_OOZIE}"
    svc_RANGER          = "${var.svc_RANGER}"
    svc_SOLR            = "${var.svc_SOLR}"
    svc_SPARK_ON_YARN   = "${var.svc_SPARK_ON_YARN}"
    svc_SQOOP_CLIENT    = "${var.svc_SQOOP_CLIENT}"
    svc_YARN            = "${var.svc_YARN}"
    enable_debug	= "${var.enable_debug}"
    rangeradmin_password = "${var.rangeradmin_password}"
    yarn_scheduler	= "${var.yarn_scheduler}"
  }

  timeouts {
    create = "30m"
  }
}
// Block Volume Creation for Utility 

# Log Volume for /var/log/cloudera
resource "oci_core_volume" "UtilLogVolume" {
  count = 1
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Cloudera Manager ${format("%01d", count.index+1)} Log Data"
  size_in_gbs         = "${var.log_volume_size_in_gbs}"
}

resource "oci_core_volume_attachment" "UtilLogAttachment" {
  count = 1
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.Utility.id}"
  volume_id       = "${oci_core_volume.UtilLogVolume.*.id[count.index]}"
  device          = "/dev/oracleoci/oraclevdb"
}

# Data Volume for /opt/cloudera
resource "oci_core_volume" "UtilClouderaVolume" {
  count = 1
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Cloudera Manager ${format("%01d", count.index+1)} Data"
  size_in_gbs         = "${var.cloudera_volume_size_in_gbs}"
}

resource "oci_core_volume_attachment" "UtilClouderaAttachment" {
  count = 1
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.Utility.id}"
  volume_id       = "${oci_core_volume.UtilClouderaVolume.*.id[count.index]}"
  device          = "/dev/oracleoci/oraclevdc"
}
