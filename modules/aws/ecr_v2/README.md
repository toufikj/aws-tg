<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_counts"></a> [counts](#input\_counts) | Number of ECR repositories to create | `any` | n/a | yes |
| <a name="input_names"></a> [names](#input\_names) | List of names for ECR repositories | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | List of URLs for the created ECR repositories |
<!-- END_TF_DOCS -->