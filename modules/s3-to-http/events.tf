locals {
  api_name = var.name  # Alias to the API connection name
  
  rules = {  # Collect event rules for each S3 path
    for label, path in var.s3_paths:
    (label) => merge(regex("s3://(?P<bucket>[^/]+)/(?P<prefix>[^$]+)", path), {
      name = "${var.name}-${label}"
      # bucket = from regex
      # prefix = from regex
    })
  }
}

module "events" {
  source = "terraform-aws-modules/eventbridge/aws"
  version = "~> 1.0"

  # aws.* events go to default ONLY
  create_bus = false
  bus_name = "default"

  # Toggle API destination
  attach_api_destination_policy = true
  create_connections = true
  create_api_destinations = true

  # Set up permissions in IAM
  create_role = true
  role_name = "${var.name}-events"

  connections = {
    (local.api_name) = {  # A single connection per module instance, for now
      authorization_type = "API_KEY"
      auth_parameters = {
        api_key = {  # TODO: actually authenticate
          key = "undefined"
          value = "undefined"
        }
      }
    }
  }

  api_destinations = {
    (local.api_name) = {  # A single API destination per module instance, for now
      invocation_endpoint = var.url
      http_method = "POST"
    }
  }

  rules = {
    for label, rule in local.rules:
    (rule.name) => {
      event_pattern = replace(replace(jsonencode({
        "source": ["aws.s3"],
        "detail-type": ["Object Created"],
        "detail": {
          "bucket": { "name": [rule.bucket] }
          "object": {
            "key": [{ "prefix": rule.prefix }],
            "size": [{ "numeric": [ ">", 0 ] }],  # Avoid new folders (size = 0)
          }
        },
      }), "\\u003c", "<"), "\\u003e", ">")  # Terraform escapes < and >
    }
  }

  targets = {
    for label, rule in local.rules:
    (rule.name) => [
      {
        name = rule.name
        destination = local.api_name
        attach_role_arn = true
        input_transformer = {
          input_paths = {
            bucket = "$.detail.bucket.name"
            key = "$.detail.object.key"
            size = "$.detail.object.size"
            etag = "$.detail.object.etag"
          }
          input_template = replace(replace(jsonencode({
            "bucket": "<bucket>",
            "key": "<key>",
            "size": "<size>",
            "etag": "<etag>",
          }), "\\u003c", "<"), "\\u003e", ">")  # Terraform escapes < and >
        }
      },
    ]
  }
}
