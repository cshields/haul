module "worker" {
  source            = "github.com/nubisproject/nubis-terraform//worker?ref=v1.4.0"
  region            = "${var.region}"
  environment       = "${var.environment}"
  account           = "${var.account}"
  service_name      = "${var.service_name}"
  purpose           = "webserver"
  instance_type     = "t2.medium"
  root_storage_size = "64"
  ami               = "${var.ami}"
  elb               = "${module.load_balancer.name}"
  ssh_key_file      = "${var.ssh_key_file}"
  ssh_key_name      = "${var.ssh_key_name}"
  min_instances     = 1
}

module "load_balancer" {
  source       = "github.com/nubisproject/nubis-terraform//load_balancer?ref=v1.4.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"

  # We are a unusual Load Balancer with raw connectivity
  no_ssl_cert        = "1"
  backend_protocol   = "tcp"
  protocol_http      = "tcp"
  protocol_https     = "tcp"
  backend_port_http  = "80"
  backend_port_https = "443"

  health_check_target = "TCP:80"
}

module "dns" {
  source       = "github.com/nubisproject/nubis-terraform//dns?ref=v1.4.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  target       = "${module.load_balancer.address}"
}

module "tlscanary" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name  = "tlscanary"
  site_index = "index.htm"
}

module "nightly" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name      = "nightly"
  site_frequency = "H/15 * * * *"
}

module "archive" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name = "archive"
}

module "bugzilla" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name = "bugzilla"
}

module "services" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name = "services"
}

module "sso" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name = "sso"
}

module "publicsuffix" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name = "publicsuffix"
}

module "trackertest" {
  source = "sites"

  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  role         = "${module.worker.role}"

  site_name = "trackertest"
}
