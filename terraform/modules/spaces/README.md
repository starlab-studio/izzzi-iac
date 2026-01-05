# Spaces Module

Module Terraform pour créer et gérer les buckets Digital Ocean Spaces pour l'infrastructure IZZZI.

## Description

Ce module crée les buckets Spaces nécessaires pour:

- **Terraform State**: Stockage du state Terraform (backend remote)
- **Backups**: Stockage des backups de base de données
- **Assets** (optionnel): Stockage des assets uploadés par les utilisateurs

## Utilisation

```hcl
module "spaces" {
  source = "../../modules/spaces"

  project_name = "izzzi"
  environment  = "staging"
  region       = "fra1"

  create_assets_bucket = true
  assets_bucket_acl    = "public-read"

  allowed_origins = [
    "https://staging.izzzi.com",
    "https://www.staging.izzzi.com"
  ]

  backup_retention_days = 90

  # Credentials Spaces (do not create new keys, use existing)
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key

  common_tags = {
    Project     = "izzzi"
    ManagedBy   = "terraform"
    Environment = "staging"
  }
}
```

## Variables

| Nom                     | Type           | Description                                                | Défaut      | Requis |
| ----------------------- | -------------- | ---------------------------------------------------------- | ----------- | ------ |
| `project_name`          | `string`       | Nom du projet (utilisé pour le nommage et les tags)        | -           | Oui    |
| `environment`           | `string`       | Nom de l'environnement (staging, production, dev)          | -           | Oui    |
| `region`                | `string`       | Région Digital Ocean Spaces (fra1, ams3, nyc3, sgp1, sfo3) | -           | Oui    |
| `create_assets_bucket`  | `bool`         | Créer le bucket assets pour les uploads utilisateurs       | `false`     | Non    |
| `assets_bucket_acl`     | `string`       | ACL du bucket assets (private ou public-read)              | `"private"` | Non    |
| `backup_retention_days` | `number`       | Nombre de jours de rétention des backups (1-365)           | `90`        | Non    |
| `allowed_origins`       | `list(string)` | Liste des origines CORS autorisées pour le bucket assets   | `[]`        | Non    |
| `spaces_access_id`      | `string`       | Access Key ID Spaces (sensible, pour backend config)       | `""`        | Non    |
| `spaces_secret_key`     | `string`       | Secret Access Key Spaces (sensible, pour backend config)   | `""`        | Non    |
| `common_tags`           | `map(string)`  | Tags communs à appliquer aux ressources                    | `{}`        | Non    |

## Outputs

| Nom                               | Description                                      |
| --------------------------------- | ------------------------------------------------ |
| `terraform_state_bucket_name`     | Nom du bucket Terraform state                    |
| `terraform_state_bucket_urn`      | URN du bucket Terraform state                    |
| `terraform_state_bucket_endpoint` | Endpoint URL du bucket Terraform state           |
| `backups_bucket_name`             | Nom du bucket backups                            |
| `backups_bucket_urn`              | URN du bucket backups                            |
| `backups_bucket_endpoint`         | Endpoint URL du bucket backups                   |
| `assets_bucket_name`              | Nom du bucket assets (vide si non créé)          |
| `assets_bucket_urn`               | URN du bucket assets (vide si non créé)          |
| `assets_bucket_endpoint`          | Endpoint URL du bucket assets (vide si non créé) |
| `spaces_access_id`                | Access Key ID Spaces (sensible)                  |
| `spaces_secret_key`               | Secret Access Key Spaces (sensible)              |
| `spaces_endpoint`                 | Endpoint URL Spaces pour la région               |

## Configuration des Buckets

### Terraform State Bucket

- **ACL**: `private`
- **Versioning**: À configurer manuellement via l'API ou le dashboard Digital Ocean (recommandé: activé avec 30 versions)
- **Lifecycle**: À configurer manuellement (recommandé: garder 30 versions)
- **Protection**: `prevent_destroy = true` pour éviter la suppression accidentelle

### Backups Bucket

- **ACL**: `private`
- **Lifecycle**: À configurer manuellement via l'API ou le dashboard (recommandé: supprimer après `backup_retention_days`)
- **Usage**: Stockage des backups PostgreSQL et Redis

### Assets Bucket (optionnel)

- **ACL**: Configurable (`private` ou `public-read`)
- **CORS**: Configuré automatiquement si `public-read` et `allowed_origins` fourni
- **Usage**: Stockage des fichiers uploadés par les utilisateurs (images, documents, etc.)

## Configuration du Backend Terraform

Utilisez les outputs du module pour configurer le backend Terraform:

```hcl
# Dans envs/dev/backend.tf ou envs/prod/backend.tf
terraform {
  backend "s3" {
    endpoint                    = module.spaces.spaces_endpoint
    region                      = "fra1"
    bucket                      = module.spaces.terraform_state_bucket_name
    key                         = "dev/terraform.tfstate"
    encrypt                     = true
    skip_credentials_validation = true
    skip_region_validation      = true
    access_key                  = module.spaces.spaces_access_id
    secret_key                  = module.spaces.spaces_secret_key
  }
}
```

## Credentials Spaces

**Important**: Ce module ne crée PAS de nouvelles clés API Spaces. Vous devez:

1. Créer manuellement les credentials Spaces dans le dashboard Digital Ocean:

   - Allez dans "API" > "Spaces Keys"
   - Créez une nouvelle clé avec les permissions appropriées

2. Fournir les credentials via des variables:

   ```hcl
   spaces_access_id  = var.spaces_access_id
   spaces_secret_key = var.spaces_secret_key
   ```

3. Stockez les credentials de manière sécurisée (secrets manager, variables d'environnement, etc.)

## Conventions de nommage

Les buckets suivent la convention: `{project_name}-{environment}-{purpose}`

Exemples:

- `izzzi-staging-terraform-state`
- `izzzi-staging-backups`
- `izzzi-staging-assets`

## Configuration Lifecycle et Versioning

Le provider Terraform Digital Ocean a des limitations pour la configuration directe des lifecycle rules et du versioning. Vous devez les configurer manuellement:

### Via l'API Digital Ocean

```bash
# Activer le versioning pour le bucket terraform-state
# Utiliser l'API Spaces (S3-compatible) ou le dashboard
```

### Via le Dashboard Digital Ocean

1. Allez dans "Spaces" > Sélectionnez le bucket
2. Configurez les règles de lifecycle
3. Activez le versioning si nécessaire

### Recommandations

**Terraform State Bucket:**

- Versioning: Activé
- Lifecycle: Garder les 30 dernières versions
- Protection: Ne jamais supprimer automatiquement

**Backups Bucket:**

- Lifecycle: Supprimer les objets après `backup_retention_days` (90 jours par défaut)
- Versioning: Optionnel (désactivé par défaut)

**Assets Bucket:**

- Lifecycle: Configurer selon les besoins (ex: supprimer après 1 an d'inactivité)
- Versioning: Optionnel

## CORS Configuration

**Important**: Le provider Terraform Digital Ocean ne supporte pas la configuration CORS directement. If faudra configurer CORS manuellement via l'API ou le dashboard Digital Ocean.

Pour configurer CORS pour le bucket assets:

1. **Via le Dashboard Digital Ocean**:

   - Aller dans "Spaces" > Sélectionnez le bucket assets
   - Configurer les règles CORS avec les origines autorisées

2. **Via l'API S3-compatible**:

   ```bash
   # Utiliser aws-cli avec l'endpoint Digital Ocean
   aws s3api put-bucket-cors \
     --bucket izzzi-staging-assets \
     --endpoint https://fra1.digitaloceanspaces.com \
     --cors-configuration file://cors.json
   ```

3. **Fichier cors.json** (exemple):
   ```json
   {
     "CORSRules": [
       {
         "AllowedHeaders": ["*"],
         "AllowedMethods": ["GET", "HEAD", "PUT", "POST", "DELETE"],
         "AllowedOrigins": [
           "https://staging.izzzi.com",
           "https://www.staging.izzzi.com"
         ],
         "ExposeHeaders": ["ETag"],
         "MaxAgeSeconds": 3000
       }
     ]
   }
   ```

Utiliser la variable `allowed_origins` comme référence pour la configuration manuelle.

## Sécurité

### Recommandations pour la production

1. **Terraform State**: Toujours privé, versioning activé, chiffrement activé
2. **Backups**: Toujours privé, lifecycle configuré pour suppression automatique
3. **Assets**:
   - Utiliser `public-read` uniquement si nécessaire pour CDN
   - Configurer CORS restrictivement
   - Considérer Cloudflare ou autre CDN devant le bucket

### Pour le staging/dev

- Même configuration recommandée pour la cohérence
- Peut réduire la rétention des backups si nécessaire

## Lifecycle

- **Terraform State**: `prevent_destroy = true` pour éviter la suppression accidentelle
- **Backups et Assets**: `prevent_destroy = false` pour permettre la suppression si nécessaire

## Exemple d'utilisation complète

```hcl
# Créer les buckets
module "spaces" {
  source = "../../modules/spaces"

  project_name = "izzzi"
  environment  = "production"
  region       = "fra1"

  create_assets_bucket = true
  assets_bucket_acl    = "public-read"

  allowed_origins = [
    "https://izzzi.com",
    "https://www.izzzi.com"
  ]

  backup_retention_days = 90

  spaces_access_id  = var.spaces_access_id
  spaces_secret_key  = var.spaces_secret_key

  common_tags = {
    Project     = "izzzi"
    ManagedBy   = "terraform"
    Environment = "production"
  }
}

# Utiliser les outputs pour configurer le backend
# (dans backend.tf)
```

## Notes importantes

1. **Régions Spaces**: Les régions Spaces peuvent différer des régions Droplets. Vérifier la disponibilité.

2. **Lifecycle Rules**: À configurer manuellement via l'API ou le dashboard après la création des buckets.

3. **Versioning**: À activer manuellement pour le bucket terraform-state via le dashboard.

4. **Credentials**: Ne jamais commiter jamais les credentials Spaces dans le code. Utiliser des variables d'environnement ou un gestionnaire de secrets.
