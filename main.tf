locals {
  assume_role_policy_principals = {
    services_only = [
      {
        type        = "Service"
        identifiers = var.assume_role_services
      },
    ]
    aws_entities_only = [
      {
        type        = "AWS"
        identifiers = var.assume_role_aws_entities
      },
    ]
    services_and_entities = [
      {
        type        = "Service"
        identifiers = var.assume_role_services
      },
      {
        type        = "AWS"
        identifiers = var.assume_role_aws_entities
      },
    ]
    unspecified = []
  }

  default_instance_profile_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  inline_policies_with_vars = { for policy in var.iam_inline_policies :
    trimsuffix(element(split("/", policy.policy_file_path), length(split("/", policy.policy_file_path)) - 1), ".json") => policy if var.iam_role-create
  }

  managed_policies_with_vars = { for policy in var.iam_managed_policies :
    trimsuffix(element(split("/", policy.policy_file_path), length(split("/", policy.policy_file_path)) - 1), ".json") => policy if var.iam_role-create
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.iam_role-create ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    dynamic "principals" {
      for_each = local.assume_role_policy_principals[
        length(var.assume_role_services) > 0 && length(var.assume_role_aws_entities) == 0 ? "services_only" : length(var.assume_role_services) == 0 && length(var.assume_role_aws_entities) > 0 ? "aws_entities_only" : length(var.assume_role_services) > 0 && length(var.assume_role_aws_entities) > 0 ? "services_and_entities" : "unspecified"
      ]
      content {
        identifiers = principals.value.identifiers
        type        = principals.value.type
      }
    }
  }
}

################
# Create Roles #
################
resource "aws_iam_role" "this" {
  count              = var.iam_role-create ? 1 : 0
  name               = "${var.resource_name_pattern}-role"
  path               = var.iam_role_path
  assume_role_policy = var.assume_role_policy_document != "" ? var.assume_role_policy_document : data.aws_iam_policy_document.assume_role_policy[0].json

  tags = var.tags
}

###########################
# Create Instance Profile #
###########################
resource "aws_iam_instance_profile" "this" {
  count = var.iam_instance_profile-create && var.iam_role-create ? 1 : 0
  name  = "${var.resource_name_pattern}-profile"
  role  = aws_iam_role.this[0].name
}

###########################
# Create Managed Policies #
###########################
resource "aws_iam_policy" "this" {
  for_each = local.managed_policies_with_vars

  name        = "${var.resource_name_pattern}-${each.key}"
  path        = lookup(each.value, "policy_path", "/")
  description = lookup(each.value, "description", "Managed by Terraform.")
  policy      = templatefile(lookup(each.value, "policy_file_path"), lookup(each.value, "policy_vars", {}))
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = aws_iam_policy.this

  role       = aws_iam_role.this[0].name
  policy_arn = each.value.arn
}

##########################
# Create Inline Policies #
##########################
resource "aws_iam_role_policy" "this" {
  for_each = local.inline_policies_with_vars

  name   = "${var.resource_name_pattern}-${each.key}"
  role   = aws_iam_role.this[0].name
  policy = templatefile(lookup(each.value, "policy_file_path"), lookup(each.value, "policy_vars", {}))
}

###########################
# Create Default Policies #
###########################
resource "aws_iam_role_policy" "default" {
  count = length(var.iam_use_default_policies) >= 1 && var.iam_role-create ? length(var.iam_use_default_policies) : 0
  name  = "${element(var.iam_use_default_policies, count.index)}-default_policy"
  role  = aws_iam_role.this[0].name
  policy = file(
    "${path.module}/policies/${element(var.iam_use_default_policies, count.index)}.default_policy.json",
  )
}

#################################
# Attach Known Policies to Role #
#################################
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count      = length(var.iam_role_policies_arns) > 0 && var.iam_role-create ? length(var.iam_role_policies_arns) : 0
  policy_arn = var.iam_role_policies_arns[count.index]

  role = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "instance_profile_policy_attachment" {
  count      = var.iam_role-create && var.iam_instance_profile-create ? length(local.default_instance_profile_policy_arns) : 0
  policy_arn = local.default_instance_profile_policy_arns[count.index]

  role = aws_iam_role.this[0].name
}

