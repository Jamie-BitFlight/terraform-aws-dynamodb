module "dynamodb_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

resource "aws_dynamodb_table" "default" {
  name           = "${module.dynamodb_label.id}"
  read_capacity  = "${var.autoscale_min_read_capacity}"
  write_capacity = "${var.autoscale_min_write_capacity}"
  hash_key       = "${var.hash_key}"
  range_key      = "${var.range_key}"

  server_side_encryption {
    enabled = "${var.enable_encryption}"
  }

  lifecycle {
    ignore_changes = ["read_capacity", "write_capacity"]
  }

  attribute {
    name = "${var.hash_key}"
    type = "S"
  }

  attribute {
    name = "${var.range_key}"
    type = "S"
  }

  ttl {
    attribute_name = "${var.ttl_attribute}"
    enabled        = true
  }

  tags = "${module.dynamodb_label.tags}"
}

module "dynamodb_autoscaler" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-dynamodb-autoscaler.git?ref=tags/0.1.1"
  enabled                      = "${var.enable_autoscaler}"
  namespace                    = "${var.namespace}"
  stage                        = "${var.stage}"
  name                         = "${var.name}"
  delimiter                    = "${var.delimiter}"
  attributes                   = "${var.attributes}"
  dynamodb_table_name          = "${aws_dynamodb_table.default.id}"
  dynamodb_table_arn           = "${aws_dynamodb_table.default.arn}"
  autoscale_write_target       = "${var.autoscale_write_target}"
  autoscale_read_target        = "${var.autoscale_read_target}"
  autoscale_min_read_capacity  = "${var.autoscale_min_read_capacity}"
  autoscale_max_read_capacity  = "${var.autoscale_max_read_capacity}"
  autoscale_min_write_capacity = "${var.autoscale_min_write_capacity}"
  autoscale_max_write_capacity = "${var.autoscale_max_write_capacity}"
}
