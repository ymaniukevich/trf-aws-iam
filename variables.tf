variable "resource_name_pattern" {
  description = <<EOD
Pattern for resources names. |
**Required** |
```
"ga-eu-dev-iad"
```
EOD

  type = string
}

variable "iam_role-create" {
  description = <<EOD
Need for creating iam role. |
**Optional** |
EOD

  type    = bool
  default = true
}

variable "iam_role_path" {
  description = <<EOD
The path to the role. |
**Optional** |
EOD

  type    = string
  default = "/"
}

variable "iam_instance_profile-create" {
  description = <<EOD
Specify false in case you need Instance Profile to be not created, otherwise true. |
**Optional** |
EOD

  type    = bool
  default = false
}

variable "assume_role_services" {
  description = <<EOD
Assume role services for the role. |
**Optional** |
```
["ecs.amazonaws.com", "ec2.amazonaws.com"]
```
EOD

  type    = list(string)
  default = []
}

variable "iam_use_default_policies" {
  description = <<EOD
Specify the names of the services for which you want to use default policies. |
**Optional** |
```
["ecs"]
```
EOD

  type    = list(string)
  default = []
}

variable "iam_role_policies_arns" {
  description = <<EOD
Policies ARNs for the role. |
**Optional** |
```
[
  "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
]
```
EOD

  type    = list(string)
  default = []
}

variable "iam_managed_policies" {
  description = <<EOD
Specify a list of policy file paths and variables for them if you need interpolation. More info about managed policies you can find [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#aws-managed-policies). |
**Optional** |
```
[
  {
    policy_file_path = "policies/policy_1.json"
    description = "Managed by Terraform."
    policy_path = "/"
  },
  {
    policy_file_path = "policies/policy_2.json"
    description = "Managed by Terraform."
    policy_vars = {
      var1 = "value1"
      var2 = "value2"
      var3 = module.ecs_iam_execution_role.iam_role_arn
    }
  }
]
```
EOD

  type    = any
  default = []
}

variable "tags" {
  description = <<EOD
You can specify tags for the resources using this parameter. |
**Optional** |
```
{
  tag_name1 = "tag_value1"
  tag_name2 = "tag_value2"
}
```
EOD

  type    = map(string)
  default = {}
}

variable "iam_inline_policies" {
  description = <<EOD
Specify a list of policy file paths and variables for them if you need interpolation. More info about inline policies you can find [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#inline-policies). |
**Optional** |
```
[
  {
    policy_file_path = "policies/policy_1.json"
  },
  {
    policy_file_path = "policies/policy_2.json"
    policy_vars = {
      var1 = "value1"
      var2 = "value2"
      var3 = module.ecs_iam_execution_role.iam_role_arn
    }
  }
]
```
EOD

  type    = any
  default = []
}

variable "assume_role_aws_entities" {
  description = <<EOD
The list of assumed principles (trusted entities) of AWS type the role will contain. |
**Optional** |
```
["arn:aws:iam::752717405135:user/username"]
```
EOD

  type    = list(string)
  default = []
}

variable "assume_role_policy_document" {
  description = <<EOD
Assume policy document for specifying trusted entities of the role. The effect of using this variable overrides the one of `assume_role_services` and `assume_role_aws_entities`. |
**Optional** |
```
"{
  'Version': '2012-10-17',
  'Statement': [
    {
      'Sid': '',
      'Effect': 'Allow',
      'Action': 'sts:AssumeRole',
      'Principal': {
        'AWS': [
          'arn:aws:iam::752748192946:role/msc-eu-prod-network-jnks-role',
          'arn:aws:iam::752717405135:user/username',
          'arn:aws:iam::752717405135:user/username1',
          'arn:aws:iam::752717405135:user/username2',
          'arn:aws:iam::752717405135:user/username3',
          'arn:aws:iam::690612908881:user/username4'
        ]
      }
    }
  ]
}"
```
EOD

  type    = string
  default = ""
}
