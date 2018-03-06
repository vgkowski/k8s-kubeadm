output "cloud_config" {
  value = ["${data.template_file.cloud_config.*.rendered}"]
}