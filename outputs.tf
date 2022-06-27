output "iam_role_name" {
  description = <<EOD
    The name of the role. |
```
IAD-stg-role
```
EOD

  value = length(aws_iam_role.this) == 0 ? "" : aws_iam_role.this[0].name
}

output "iam_role_arn" {
  description = <<EOD
    The ARN specifying the role. |
```
arn:aws:iam::690612908881:role/IAD-stg-role
```
EOD

  value = length(aws_iam_role.this) == 0 ? "" : aws_iam_role.this[0].arn
}

output "iam_managed_policy_arn" {
  description = <<EOD
    The ARN of the managed policy. |
```
[
  "arn:aws:iam::690612908881:policy/ReadCloudFormation",
]
```
EOD

  value = [for attach in aws_iam_role_policy_attachment.this : attach.policy_arn]
}

output "iam_inline_policy_id" {
  description = <<EOD
    The ID of the inline policy. |
```
[
  "IAD-stg-role:FullAccessEC2_S3",
  "IAD-stg-role:ReadAccessDynamoDB",
]
```
EOD

  value = [for policy in aws_iam_role_policy.this : policy.id]
}

output "iam_policy_arn" {
  description = <<EOD
    The ARN of the policy. |
```
[
  "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
  "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
]
```
EOD

  value = aws_iam_role_policy_attachment.policy_attachment[*].policy_arn
}

output "iam_instance_profile_id" {
  description = <<EOD
    The instance profile's ID. |
```
IAD-stg-profile
```
EOD

  value = length(aws_iam_instance_profile.this) == 0 ? "" : aws_iam_instance_profile.this[0].id
}

output "iam_instance_profile_arn" {
  description = <<EOD
    The instance profile's ARN. |
```
arn:aws:iam::690612908881:instance-profile/iad-eu-dev_iad-import-intap-profile
```
EOD

  value = length(aws_iam_instance_profile.this) == 0 ? "" : aws_iam_instance_profile.this[0].arn
}

