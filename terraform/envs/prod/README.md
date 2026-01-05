# Environnement PRODUCTION - Configuration Terraform

Configuration Terraform pour l'environnement de production IZZZI.

## Architecture

- **1 Manager Node** (s-2vcpu-4gb): Héberge Docker Swarm manager + PostgreSQL + Redis
- **2 Worker Nodes** (s-2vcpu-4gb): Workers Docker Swarm pour les services applicatifs
- **VPC**: Réseau privé isolé
- **Firewalls**: Web, Internal, Management
- **Domaine**: `izzzi.app` (racine, sans préfixe)
- **Backups**: Activés (weekly sur le manager)

## Prérequis

1. Compte Digital Ocean avec API token
2. Bucket Spaces configuré pour le backend Terraform (`izzzi-terraform-state`)
3. Clé SSH publique pour l'accès aux droplets
4. Credentials Spaces (Access Key ID et Secret Key) pour le backend
5. **Liste des IPs autorisées pour SSH** (obligatoire en production)

## Configuration initiale

### 1. Copier le fichier de variables d'exemple

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configurer les variables

Éditez `terraform.tfvars` ou utilisez des variables d'environnement:

```bash
# Variables sensibles (recommandé via environnement)
export TF_VAR_do_token="dop_v1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
export TF_VAR_spaces_access_id="your-spaces-access-key"
export TF_VAR_spaces_secret_key="your-spaces-secret-key"
export TF_VAR_database_user="izzzi_user"
export TF_VAR_database_password="your-secure-password"
```

### 3. ⚠️ Configuration SSH obligatoire

**IMPORTANT**: En production, vous DEVEZ spécifier les IPs autorisées pour SSH dans `terraform.tfvars`:

```hcl
allowed_ssh_ips = [
  "203.0.113.0/24",   # Office network
  "198.51.100.0/24",  # VPN network
  "192.0.2.100/32"    # Specific IP
]
```

**La validation Terraform empêchera le déploiement si:**

- `allowed_ssh_ips` est vide
- `allowed_ssh_ips` contient `"0.0.0.0/0"`

### 4. Initialiser Terraform

```bash
terraform init
```

### 5. Vérifier le plan

```bash
terraform plan
```

### 6. Appliquer la configuration

```bash
terraform apply
```

## Configuration du Backend

Le backend est configuré dans `backend.tf` pour utiliser Digital Ocean Spaces:

- **Bucket**: `izzzi-terraform-state`
- **Key**: `production/terraform.tfstate`
- **Region**: `fra1`
- **Endpoint**: `https://fra1.digitaloceanspaces.com`

Les credentials Spaces doivent être fournis via:

- Variables d'environnement `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` (pour compatibilité S3)
- Ou configurés dans le backend config

## Variables principales

| Variable          | Description                                  | Défaut         | Requis |
| ----------------- | -------------------------------------------- | -------------- | ------ |
| `do_token`        | Token API Digital Ocean                      | -              | Oui    |
| `region`          | Région (fra1 ou ams3)                        | `fra1`         | Non    |
| `domain_name`     | Domaine de base                              | `izzzi.app`    | Non    |
| `vpc_cidr`        | CIDR du VPC                                  | `10.10.0.0/16` | Non    |
| `ssh_public_key`  | Clé SSH publique                             | -              | Oui    |
| `allowed_ssh_ips` | IPs autorisées pour SSH (validation stricte) | `[]`           | Oui    |

## Outputs

Après `terraform apply`, vous obtiendrez:

- **manager_ip**: IP publique du manager
- **worker_ips**: Liste des IPs des workers (2 workers)
- **api_url**: URL de l'API (`https://api.izzzi.app`)
- **ai_url**: URL du service AI (`https://ai.izzzi.app`)
- **frontend_url**: URL du frontend (`https://izzzi.app`)
- **database_info**: Informations PostgreSQL (sur manager)
- **redis_info**: Informations Redis (sur manager)
- **database_connection_string_template**: Template de connexion DB
- **backup_policy**: Détails de la politique de backup
- **estimated_monthly_cost**: Estimation des coûts mensuels
- **ssh_command**: Commande SSH pour se connecter
- **swarm_init_command**: Commande pour initialiser Swarm
- **swarm_join_command_placeholder**: Placeholder pour join token
- **security_info**: Informations de sécurité

## Initialisation Docker Swarm

Après le déploiement:

1. **Se connecter au manager**:

   ```bash
   ssh deploy@<manager_ip>
   ```

2. **Initialiser Swarm**:

   ```bash
   docker swarm init --advertise-addr <manager_private_ip>
   ```

3. **Obtenir le token pour les workers**:

   ```bash
   docker swarm join-token worker
   ```

4. **Sur chaque worker, joindre le cluster**:

   ```bash
   ssh deploy@<worker_ip>
   docker swarm join --token <token> <manager_private_ip>:2377
   ```

## Architecture Production

### Droplets

- **Manager** (s-2vcpu-4gb): Swarm manager + PostgreSQL + Redis
- **Workers** (2x s-2vcpu-4gb): Services applicatifs (Next.js, NestJS, FastAPI)

### Base de données

- **PostgreSQL**: Instance unique sur le manager (port 5432)

  - Schéma `public`: Backend NestJS
  - Schéma `ai`: Service FastAPI
  - Extension `pgvector` activée

- **Redis**: Instance unique sur le manager (port 6379)

  - DB 0: Cache backend
  - DB 1: Cache AI service
  - DB 2: Celery broker
  - DB 3: Celery results

- **Manager label**: `db=true` pour identifier le node hébergeant les bases de données

### Backups

- **Activés**: Weekly backups sur le manager node
- **Rétention**: 30 jours (configurable)
- **Coût**: ~20% du coût du droplet (environ $4.80/mois pour s-2vcpu-4gb)

## Sécurité Production

### Mesures de sécurité

✅ **SSH restreint**: Accès SSH limité aux IPs spécifiées (validation Terraform)

✅ **Backups activés**: Weekly backups sur le node DB

✅ **Monitoring activé**: Surveillance Digital Ocean activée

✅ **Firewalls**: 3 firewalls distincts (Web, Internal, Management)

✅ **VPC isolé**: Communication interne via réseau privé

### Recommandations

1. **SSH**: Utilisez un VPN ou un bastion host pour l'accès SSH
2. **Backups**: Configurez également des backups applicatifs vers Spaces
3. **Monitoring**: Configurez des alertes pour les métriques critiques
4. **Secrets**: Utilisez un gestionnaire de secrets (Vault, AWS Secrets Manager, etc.)
5. **SSL/TLS**: Configurez des certificats SSL valides pour tous les domaines

## Coûts estimés

Voir l'output `estimated_monthly_cost` pour une estimation détaillée:

- **Manager**: ~$28.80/mois (droplet + backups)
- **Workers** (2x): ~$48.00/mois
- **Total droplets**: ~$76.80/mois
- **VPC, Firewalls, Monitoring**: Gratuits

⚠️ **Note**: Les coûts réels peuvent varier selon:

- Utilisation de la bande passante
- Stockage Spaces
- Snapshots additionnels
- Autres services Digital Ocean

## Destruction

Pour détruire l'infrastructure:

```bash
terraform destroy
```

⚠️ **Attention**:

- Le bucket Terraform state est protégé (`prevent_destroy = true`)
- Les backups seront supprimés avec les droplets
- **Assurez-vous d'avoir des backups externes avant destruction**

## Troubleshooting

### Erreur de validation SSH

Si vous obtenez une erreur sur `allowed_ssh_ips`:

```
Error: allowed_ssh_ips must not be empty and must not contain 0.0.0.0/0
```

**Solution**: Spécifiez des IPs/CIDR valides dans `terraform.tfvars`:

```hcl
allowed_ssh_ips = ["203.0.113.0/24", "198.51.100.0/24"]
```

### Erreur de backend

Si vous obtenez une erreur de backend, vérifiez:

1. Le bucket Spaces existe
2. Les credentials Spaces sont corrects
3. L'endpoint est correct pour la région
4. La clé `production/terraform.tfstate` est accessible

### Erreur SSH key

Si la clé SSH n'est pas trouvée:

1. Vérifiez qu'elle existe dans Digital Ocean
2. Ou laissez le module la créer automatiquement

### Module DNS manquant

Le module DNS n'est pas encore créé. Les URLs dans les outputs sont des placeholders.
Une fois le module DNS créé, décommentez l'appel dans `main.tf`.

## Différences avec DEV

| Aspect         | DEV                | PRODUCTION            |
| -------------- | ------------------ | --------------------- |
| Workers        | 1 (s-2vcpu-2gb)    | 2 (s-2vcpu-4gb)       |
| Backups        | Désactivés         | Activés (weekly)      |
| SSH Access     | 0.0.0.0/0 (ouvert) | IPs spécifiques       |
| Domaine        | dev.izzzi.app      | izzzi.app             |
| Monitoring     | Activé             | Activé                |
| Validation SSH | Permissive         | Stricte (obligatoire) |

## Notes importantes

- **SSH obligatoire**: La validation Terraform empêche le déploiement sans IPs SSH spécifiées
- **Backups**: Configurez également des backups applicatifs et des snapshots manuels si nécessaire
- **Scaling**: Pour augmenter la capacité, modifiez `worker_count` dans `main.tf`
- **High Availability**: Pour une vraie HA, considérez des instances managées PostgreSQL/Redis
- **Monitoring**: Configurez des alertes pour les métriques critiques (CPU, mémoire, disque, etc.)
