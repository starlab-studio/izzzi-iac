# Environnement DEV - Configuration Terraform

Configuration Terraform pour l'environnement de développement/staging IZZZI.

## Architecture

- **1 Manager Node** (s-2vcpu-4gb): Héberge Docker Swarm manager + PostgreSQL + Redis
- **1 Worker Node** (s-2vcpu-2gb): Worker Docker Swarm
- **VPC**: Réseau privé isolé
- **Firewalls**: Web, Internal, Management
- **Domaine**: `dev.izzzi.app` (configurable)

## Prérequis

1. Compte Digital Ocean avec API token
2. Bucket Spaces configuré pour le backend Terraform (`izzzi-terraform-state`)
3. Clé SSH publique pour l'accès aux droplets
4. Credentials Spaces (Access Key ID et Secret Key) pour le backend

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
```

### 3. Initialiser Terraform

```bash
terraform init
```

### 4. Vérifier le plan

```bash
terraform plan
```

### 5. Appliquer la configuration

```bash
terraform apply
```

## Configuration du Backend

Le backend est configuré dans `backend.tf` pour utiliser Digital Ocean Spaces:

- **Bucket**: `izzzi-terraform-state`
- **Key**: `dev/terraform.tfstate`
- **Region**: `fra1`
- **Endpoint**: `https://fra1.digitaloceanspaces.com`

Les credentials Spaces doivent être fournis via:

- Variables d'environnement `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` (pour compatibilité S3)
- Ou configurés dans le backend config

## Variables principales

| Variable          | Description             | Défaut          |
| ----------------- | ----------------------- | --------------- |
| `do_token`        | Token API Digital Ocean | -               |
| `region`          | Région (fra1 ou ams3)   | `fra1`          |
| `domain_name`     | Domaine de base         | `izzzi.app`     |
| `vpc_cidr`        | CIDR du VPC             | `10.10.0.0/16`  |
| `ssh_public_key`  | Clé SSH publique        | -               |
| `allowed_ssh_ips` | IPs autorisées pour SSH | `["0.0.0.0/0"]` |

## Outputs

Après `terraform apply`, vous obtiendrez:

- **manager_ip**: IP publique du manager
- **worker_ips**: Liste des IPs des workers
- **api_url**: URL de l'API (`https://api.dev.izzzi.app`)
- **ai_url**: URL du service AI (`https://ai.dev.izzzi.app`)
- **frontend_url**: URL du frontend (`https://dev.izzzi.app`)
- **database_info**: Informations PostgreSQL (sur manager)
- **redis_info**: Informations Redis (sur manager)
- **ssh_command**: Commande SSH pour se connecter
- **swarm_init_command**: Commande pour initialiser Swarm
- **swarm_join_command_placeholder**: Placeholder pour join token

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

## Architecture simplifiée DEV

En environnement DEV, l'architecture est simplifiée:

- **PostgreSQL**: Instance unique sur le manager (port 5432)

  - Schéma `public`: Backend NestJS
  - Schéma `ai`: Service FastAPI
  - Extension `pgvector` activée

- **Redis**: Instance unique sur le manager (port 6379)

  - DB 0: Cache
  - DB 1: Celery broker
  - DB 2: Celery results
  - DB 3: Réservé

- **Manager label**: `db=true` pour identifier le node hébergeant les bases de données

## Sécurité

⚠️ **Environnement DEV**:

- SSH ouvert depuis `0.0.0.0/0` par défaut
- Backups désactivés
- Monitoring activé

Pour la production, modifiez `allowed_ssh_ips` pour restreindre l'accès SSH.

## Destruction

Pour détruire l'infrastructure:

```bash
terraform destroy
```

⚠️ **Attention**: Le bucket Terraform state est protégé (`prevent_destroy = true`), mais les autres ressources seront supprimées.

## Troubleshooting

### Erreur de backend

Si vous obtenez une erreur de backend, vérifiez:

1. Le bucket Spaces existe
2. Les credentials Spaces sont corrects
3. L'endpoint est correct pour la région

### Erreur SSH key

Si la clé SSH n'est pas trouvée:

1. Vérifiez qu'elle existe dans Digital Ocean
2. Ou laissez le module la créer automatiquement

### Module DNS manquant

Le module DNS n'est pas encore créé. Les URLs dans les outputs sont des placeholders.
Une fois le module DNS créé, décommentez l'appel dans `main.tf`.

## Notes

- Les tailles de droplets sont optimisées pour le dev (coûts réduits)
- Le manager héberge les bases de données pour simplifier l'architecture
- En production, utilisez des instances managées pour PostgreSQL et Redis
