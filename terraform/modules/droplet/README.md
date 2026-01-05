# Droplet Module

Module Terraform pour créer et gérer les droplets Docker Swarm sur Digital Ocean.

## Description

Ce module crée une infrastructure Docker Swarm avec:

- **1 manager node**: Node principal du cluster Swarm (peut être promu en cas de failover)
- **N worker nodes**: Nodes workers configurables (peuvent être promus managers si nécessaire)
- Tous les nodes communiquent via le VPC privé
- Configuration automatique via cloud-init (Docker, firewall, outils système)

## Utilisation

```hcl
module "droplets" {
  source = "../../modules/droplet"

  project_name = "izzzi"
  environment  = "staging"
  region       = "fra1"
  vpc_id       = module.networking.vpc_id

  manager_size = "s-2vcpu-4gb"
  worker_size  = "s-2vcpu-4gb"
  worker_count = 2

  ssh_public_key = file("~/.ssh/id_rsa.pub")
  ssh_key_name   = "izzzi-staging-key"

  enable_monitoring = true
  enable_backups    = false  # Set to true for production

  common_tags = {
    Project     = "izzzi"
    ManagedBy   = "terraform"
    Environment = "staging"
  }
}
```

## Variables

| Nom                 | Type           | Description                                                       | Défaut               | Requis |
| ------------------- | -------------- | ----------------------------------------------------------------- | -------------------- | ------ |
| `project_name`      | `string`       | Nom du projet (utilisé pour le nommage et les tags)               | -                    | Oui    |
| `environment`       | `string`       | Nom de l'environnement (staging, production, dev)                 | -                    | Oui    |
| `region`            | `string`       | Région Digital Ocean (fra1 ou ams3)                               | -                    | Oui    |
| `vpc_id`            | `string`       | ID du VPC où déployer les droplets                                | -                    | Oui    |
| `manager_size`      | `string`       | Taille du droplet manager                                         | `"s-2vcpu-4gb"`      | Non    |
| `worker_size`       | `string`       | Taille des droplets workers                                       | `"s-2vcpu-4gb"`      | Non    |
| `worker_count`      | `number`       | Nombre de nodes workers (1-10)                                    | `2`                  | Non    |
| `ssh_public_key`    | `string`       | Contenu de la clé SSH publique (sensible)                         | -                    | Oui    |
| `ssh_key_name`      | `string`       | Nom de la clé SSH dans Digital Ocean                              | -                    | Oui    |
| `manager_tags`      | `list(string)` | Tags additionnels pour le manager                                 | `[]`                 | Non    |
| `worker_tags`       | `list(string)` | Tags additionnels pour les workers                                | `[]`                 | Non    |
| `droplet_image`     | `string`       | Image/snapshot du droplet                                         | `"ubuntu-24-04-x64"` | Non    |
| `enable_monitoring` | `bool`         | Activer l'agent de monitoring Digital Ocean                       | `true`               | Non    |
| `enable_backups`    | `bool`         | Activer les backups automatiques (recommandé pour production)     | `false`              | Non    |
| `enable_ipv6`       | `bool`         | Activer le support IPv6                                           | `false`              | Non    |
| `common_tags`       | `map(string)`  | Tags communs à appliquer aux ressources                           | `{}`                 | Non    |
| `do_project_id`     | `string`       | ID du projet Digital Ocean pour associer les droplets (optionnel) | `""`                 | Non    |

## Outputs

| Nom                       | Description                                               |
| ------------------------- | --------------------------------------------------------- |
| `manager_id`              | ID du droplet manager                                     |
| `manager_public_ip`       | IP publique du manager                                    |
| `manager_private_ip`      | IP privée du manager (dans le VPC)                        |
| `manager_urn`             | URN du droplet manager                                    |
| `worker_ids`              | Liste des IDs des droplets workers                        |
| `worker_public_ips`       | Liste des IPs publiques des workers                       |
| `worker_private_ips`      | Liste des IPs privées des workers (dans le VPC)           |
| `worker_urns`             | Liste des URNs des droplets workers                       |
| `ssh_key_fingerprint`     | Fingerprint de la clé SSH utilisée                        |
| `ssh_key_id`              | ID de la clé SSH utilisée                                 |
| `all_droplet_ips`         | Map de tous les noms de droplets vers leurs IPs publiques |
| `all_droplet_private_ips` | Map de tous les noms de droplets vers leurs IPs privées   |

## Cloud-init Configuration

Le module configure automatiquement chaque droplet avec:

### Packages installés

- Docker CE (dernière version stable)
- docker-compose plugin
- curl, htop, vim, git, jq, postgresql-client
- s3cmd (pour les backups vers Digital Ocean Spaces)

### Configuration système

- Mise à jour complète du système
- Timezone: Europe/Paris
- Utilisateur `deploy` avec accès sudo et Docker
- Logs Docker configurés (json-file avec rotation: max 10MB, 3 fichiers)

### Firewall (UFW)

Ports ouverts:

- **22/tcp**: SSH
- **80/tcp**: HTTP
- **443/tcp**: HTTPS
- **2377/tcp**: Docker Swarm management
- **7946/tcp,udp**: Docker Swarm container network discovery
- **4789/udp**: Docker Swarm overlay network

### Répertoires

- `/home/deploy/izzzi`: Répertoire de déploiement pré-créé

## Gestion de la clé SSH

Le module gère automatiquement la clé SSH:

- Si une clé avec le nom `ssh_key_name` existe déjà dans Digital Ocean, elle est utilisée
- Sinon, une nouvelle clé est créée avec le contenu fourni

## Conventions de nommage

- Manager: `{project_name}-{environment}-swarm-manager`
- Workers: `{project_name}-{environment}-swarm-worker-01`, `-02`, etc.

Exemple: `izzzi-staging-swarm-manager`, `izzzi-staging-swarm-worker-01`

## Tags automatiques

Le module applique automatiquement les tags suivants:

- Tags communs (Project, ManagedBy, Environment, Component)
- `Role:manager` ou `Role:worker`
- `Swarm:manager` ou `Swarm:worker`
- Tags additionnels via `manager_tags` et `worker_tags`

## Lifecycle

- `create_before_destroy = true`: Crée la nouvelle ressource avant de détruire l'ancienne
- Timeouts configurés: 10 minutes pour create/update, 5 minutes pour delete

## Recommandations

### Pour la production

- Activez `enable_backups = true` pour les backups automatiques
- Utilisez des tailles de droplets plus importantes (`s-4vcpu-8gb` ou plus)
- Configurez `do_project_id` pour organiser les ressources dans un projet Digital Ocean

### Pour le staging/dev

- `enable_backups = false` pour réduire les coûts
- Tailles de droplets plus petites acceptables

## Initialisation du Swarm

Après le déploiement, initialisez le Swarm manuellement:

```bash
# Sur le manager
ssh deploy@<manager_public_ip>
docker swarm init --advertise-addr <manager_private_ip>

# Obtenir le token pour les workers
docker swarm join-token worker

# Sur chaque worker
ssh deploy@<worker_public_ip>
docker swarm join --token <token> <manager_private_ip>:2377
```

## Exemple d'utilisation des outputs

```hcl
# Utiliser les IPs pour configurer d'autres services
output "swarm_manager_ip" {
  value = module.droplets.manager_public_ip
}

# Utiliser les IDs pour des dépendances
resource "some_resource" "example" {
  depends_on = [module.droplets.manager_id]
}
```
