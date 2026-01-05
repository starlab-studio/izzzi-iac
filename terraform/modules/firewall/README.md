# Firewall Module

Module Terraform pour créer et gérer les règles de firewall Digital Ocean pour sécuriser l'infrastructure IZZZI.

## Description

Ce module crée trois firewalls distincts pour séparer les préoccupations de sécurité:

1. **Web Firewall**: Gère le trafic HTTP/HTTPS public
2. **Internal Firewall**: Gère la communication interne Swarm et services (PostgreSQL, Redis)
3. **Management Firewall**: Gère l'accès SSH pour l'administration

## Utilisation

```hcl
module "firewall" {
  source = "../../modules/firewall"

  project_name = "izzzi"
  environment  = "staging"
  vpc_cidr     = "10.10.0.0/16"
  
  droplet_ids = concat(
    [module.droplets.manager_id],
    module.droplets.worker_ids
  )

  # Restrict SSH access to specific IPs (production)
  allowed_ssh_ips = [
    "203.0.113.0/24",  # Office IP range
    "198.51.100.0/24"  # VPN IP range
  ]

  common_tags = {
    Project     = "izzzi"
    ManagedBy   = "terraform"
    Environment = "staging"
  }
}
```

## Variables

| Nom                  | Type          | Description                                                      | Défaut        | Requis |
| -------------------- | ------------- | ---------------------------------------------------------------- | ------------- | ------ |
| `project_name`       | `string`      | Nom du projet (utilisé pour le nommage et les tags)              | -             | Oui    |
| `environment`        | `string`      | Nom de l'environnement (staging, production, dev)                | -             | Oui    |
| `vpc_cidr`           | `string`      | CIDR block du VPC pour les règles de firewall interne            | -             | Oui    |
| `droplet_ids`        | `list(string)`| Liste des IDs des droplets à protéger                            | -             | Oui    |
| `allowed_ssh_ips`    | `list(string)`| Liste des IPs/CIDR autorisés pour SSH                            | `["0.0.0.0/0"]`| Non    |
| `manager_droplet_ids`| `list(string)`| Liste des IDs des managers (référence, optionnel)                | `[]`           | Non    |
| `worker_droplet_ids` | `list(string)`| Liste des IDs des workers (référence, optionnel)                  | `[]`           | Non    |
| `common_tags`        | `map(string)` | Tags communs à appliquer aux ressources                          | `{}`           | Non    |

## Outputs

| Nom                    | Description                                    |
| ---------------------- | ---------------------------------------------- |
| `web_firewall_id`      | ID du firewall web (HTTP/HTTPS)                |
| `web_firewall_name`    | Nom du firewall web                             |
| `internal_firewall_id` | ID du firewall interne (Swarm/services)         |
| `internal_firewall_name`| Nom du firewall interne                        |
| `management_firewall_id`| ID du firewall management (SSH)                |
| `management_firewall_name`| Nom du firewall management                    |
| `all_firewall_ids`     | Liste de tous les IDs de firewalls              |

## Règles de Firewall

### Web Firewall

**Inbound:**
- **TCP 80** (HTTP): Depuis `0.0.0.0/0` (public)
- **TCP 443** (HTTPS): Depuis `0.0.0.0/0` (public)

**Outbound:**
- **TCP 1-65535**: Vers `0.0.0.0/0` (tous les ports)
- **UDP 1-65535**: Vers `0.0.0.0/0` (tous les ports)
- **ICMP**: Vers `0.0.0.0/0`

### Internal Firewall

**Inbound (depuis VPC CIDR uniquement):**
- **TCP 2377**: Docker Swarm management
- **TCP 7946**: Docker Swarm container network discovery
- **UDP 7946**: Docker Swarm container network discovery
- **UDP 4789**: Docker Swarm overlay network
- **TCP 5432**: PostgreSQL (single instance)
- **TCP 6379**: Redis (single instance)

**Outbound:**
- **TCP 1-65535**: Vers VPC CIDR
- **UDP 1-65535**: Vers VPC CIDR
- **ICMP**: Vers VPC CIDR

### Management Firewall

**Inbound:**
- **TCP 22** (SSH): Depuis la liste d'IPs autorisées (variable `allowed_ssh_ips`)

**Outbound:**
- **TCP 1-65535**: Vers `0.0.0.0/0` (tous les ports)
- **UDP 1-65535**: Vers `0.0.0.0/0` (tous les ports)
- **ICMP**: Vers `0.0.0.0/0`

## Conventions de nommage

Les firewalls suivent la convention: `{project_name}-{environment}-fw-{type}`

Exemples:
- `izzzi-staging-fw-web`
- `izzzi-staging-fw-internal`
- `izzzi-staging-fw-management`

## Tags automatiques

Chaque firewall reçoit automatiquement les tags suivants:
- Tags communs (Project, ManagedBy, Environment, Component)
- `Firewall:web`, `Firewall:internal`, ou `Firewall:management`
- `Type:public`, `Type:private`, ou `Type:admin`

## Sécurité

### Recommandations pour la production

1. **SSH Access**: Restreignez `allowed_ssh_ips` à des IPs spécifiques:
   ```hcl
   allowed_ssh_ips = [
     "203.0.113.0/24",  # Office network
     "198.51.100.0/24"  # VPN network
   ]
   ```

2. **VPC Isolation**: Le firewall interne garantit que les services (PostgreSQL, Redis) ne sont accessibles que depuis le VPC.

3. **Web Traffic**: Seuls les ports HTTP/HTTPS sont ouverts publiquement.

### Pour le staging/dev

- `allowed_ssh_ips = ["0.0.0.0/0"]` est acceptable pour faciliter l'accès
- Les mêmes règles de firewall s'appliquent pour la cohérence

## Lifecycle

- `create_before_destroy = true`: Crée le nouveau firewall avant de détruire l'ancien pour éviter les interruptions

## Notes importantes

1. **Tous les firewalls sont appliqués à tous les droplets**: Les règles sont combinées (union), donc un droplet peut avoir plusieurs firewalls actifs simultanément.

2. **Ordre des règles**: Digital Ocean applique les règles dans l'ordre, mais avec plusieurs firewalls, toutes les règles s'appliquent.

3. **VPC CIDR**: Le firewall interne utilise le CIDR du VPC pour restreindre l'accès aux services. Assurez-vous que le CIDR correspond à votre VPC.

4. **Services Database**: PostgreSQL (5432) et Redis (6379) sont configurés pour une instance unique. Si vous utilisez des clusters, vous devrez peut-être ajouter des règles supplémentaires.

## Exemple d'utilisation des outputs

```hcl
# Référencer les IDs de firewall dans d'autres modules
output "firewall_info" {
  value = {
    web       = module.firewall.web_firewall_id
    internal  = module.firewall.internal_firewall_id
    management = module.firewall.management_firewall_id
  }
}
```

## Intégration avec le module Droplet

```hcl
module "droplets" {
  source = "../../modules/droplet"
  # ... configuration
}

module "firewall" {
  source = "../../modules/firewall"
  
  droplet_ids = concat(
    [module.droplets.manager_id],
    module.droplets.worker_ids
  )
  
  vpc_cidr = module.networking.vpc_cidr
  # ... autres variables
}
```

