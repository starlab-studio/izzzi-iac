# DNS Module

This module creates DNS A records for the IZZZI application infrastructure.

## Overview

The module creates the following DNS records, all pointing to the manager node's public IP:

- `@` (root domain) → Manager IP
- `www` → Manager IP
- `api` → Manager IP
- `ai` → Manager IP
- `traefik` → Manager IP

All traffic is routed to the manager node, where Traefik handles routing based on the `Host` header.

## Usage

```terraform
module "dns" {
  source = "../../modules/dns"

  project_name = "izzzi"
  environment  = "production"
  domain_name  = "smoothbill.fr"

  manager_ip = module.droplets.manager_public_ip

  common_tags = {
    Project     = "izzzi"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Prerequisites

1. **Domain must be added in Digital Ocean**:

   - Go to Digital Ocean Dashboard → Networking → Domains
   - Click "Add Domain"
   - Enter your domain name (e.g., `smoothbill.fr`)
   - **Important**: Do NOT transfer the domain, only add it for DNS management

2. **Nameservers must be configured**:
   - If domain is registered elsewhere (e.g., IONOS), configure nameservers:
     - `ns1.digitalocean.com`
     - `ns2.digitalocean.com`
     - `ns3.digitalocean.com`
   - Propagation can take 24-48 hours

## Inputs

| Name           | Description                            | Type          | Default | Required |
| -------------- | -------------------------------------- | ------------- | ------- | -------- |
| `project_name` | Project name for tagging               | `string`      | n/a     | yes      |
| `environment`  | Environment name (dev, prod)           | `string`      | n/a     | yes      |
| `domain_name`  | Base domain name (e.g., smoothbill.fr) | `string`      | n/a     | yes      |
| `manager_ip`   | Public IP address of the manager node  | `string`      | n/a     | yes      |
| `common_tags`  | Common tags to apply to resources      | `map(string)` | `{}`    | no       |

## Outputs

| Name                | Description                    |
| ------------------- | ------------------------------ |
| `root_record_id`    | ID of the root A record        |
| `www_record_id`     | ID of the www A record         |
| `api_record_id`     | ID of the api A record         |
| `ai_record_id`      | ID of the ai A record          |
| `traefik_record_id` | ID of the traefik A record     |
| `all_records`       | Map of all DNS records created |
| `dns_urls`          | All DNS URLs created           |

## DNS Records Created

| Record  | Type | Name      | Value      | TTL |
| ------- | ---- | --------- | ---------- | --- |
| Root    | A    | `@`       | Manager IP | 300 |
| WWW     | A    | `www`     | Manager IP | 300 |
| API     | A    | `api`     | Manager IP | 300 |
| AI      | A    | `ai`      | Manager IP | 300 |
| Traefik | A    | `traefik` | Manager IP | 300 |

## Notes

- All subdomains point to the same IP (manager node)
- Traefik handles routing based on the `Host` header
- TTL is set to 300 seconds (5 minutes) for faster propagation during changes
- The domain must exist in Digital Ocean before applying this module
