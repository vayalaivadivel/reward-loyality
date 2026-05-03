resource "databricks_cluster" "this" {
  cluster_name  = var.cluster_name
  spark_version = "13.3.x-scala2.12"
  num_workers   = 1
}