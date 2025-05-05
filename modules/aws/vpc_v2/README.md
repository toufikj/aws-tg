<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc_subnet_module"></a> [vpc\_subnet\_module](#module\_vpc\_subnet\_module) | terraform-aws-modules/vpc/aws | >=5.8.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_vpc_subnet_module"></a> [vpc\_subnet\_module](#input\_vpc\_subnet\_module) | n/a | <pre>object({<br>    name                 = string<br>    cidr_block           = string<br>    azs                  = list(string)<br>    private_subnets      = list(string)<br>    public_subnets       = list(string)<br>    enable_ipv6          = bool<br>    enable_nat_gateway   = bool<br>    enable_vpn_gateway   = bool<br>    enable_dns_hostnames = bool<br>    enable_dns_support   = bool<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_vpc_private_subnets_ids"></a> [vpc\_private\_subnets\_ids](#output\_vpc\_private\_subnets\_ids) | n/a |
| <a name="output_vpc_public_subnets_ids"></a> [vpc\_public\_subnets\_ids](#output\_vpc\_public\_subnets\_ids) | n/a |
<!-- END_TF_DOCS -->