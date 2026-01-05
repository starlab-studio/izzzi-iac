# IZZZI Infrastructure as Code - Terraform

Infrastructure Terraform pour déployer l'application IZZZI (plateforme éducative) sur Digital Ocean.

## Architecture

- **Frontend**: Next.js
- **Backend**: NestJS
- **AI Service**: FastAPI
- **Base de données**: PostgreSQL avec pgvector (2 schémas: `public` pour backend, `ai` pour AI service)
- **Cache**: Redis partagé (différentes DBs pour cache, celery broker, celery results)
- **Orchestration**: Docker Swarm
- **Environnements**: staging et production
- **Région**: Frankfurt (fra1) ou Amsterdam (ams3)

## Prérequis

- Terraform >= 1.5.0
- Compte Digital Ocean avec API token
- Digital Ocean Spaces bucket configuré pour le backend Terraform

## Structure du projet

```
terraform/
├── modules/          # Modules réutilisables
│   ├── networking/   # Configuration réseau (VPC, etc.)
│   ├── droplet/      # Droplets (serveurs)
│   ├── database/     # Managed PostgreSQL avec pgvector
│   ├── spaces/       # Digital Ocean Spaces (stockage objet)
│   ├── firewall/     # Firewall rules
│   └── dns/          # DNS records
├── envs/             # Configurations par environnement
│   ├── dev/          # Environnement de développement/staging
│   └── prod/         # Environnement de production
├── main.tf           # Configuration principale
├── variables.tf      # Variables globales
├── outputs.tf       # Outputs globaux
├── providers.tf     # Configuration des providers
└── versions.tf      # Versions Terraform et providers
```

## Configuration du backend Terraform

Le state Terraform est stocké dans un Digital Ocean Spaces bucket. Configurez le backend dans chaque environnement (`envs/dev/backend.tf` et `envs/prod/backend.tf`).

Exemple de configuration backend:

```hcl
terraform {
  backend "s3" {
    endpoint   = "https://fra1.digitaloceanspaces.com"
    region     = "fra1"
    bucket     = "izzzi-terraform-state"
    key        = "dev/terraform.tfstate"
    encrypt    = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}
```

## Utilisation

### Initialisation

1. Configurez vos variables dans `envs/{environment}/terraform.tfvars` (copiez depuis `terraform.tfvars.example`)

2. Initialisez Terraform dans le dossier de l'environnement:

```bash
cd envs/dev
terraform init
```

3. Sélectionnez le workspace approprié (ou créez-le):

```bash
terraform workspace select staging
# ou
terraform workspace new staging
```

### Planification

```bash
terraform plan
```

### Déploiement

```bash
terraform apply
```

### Destruction

```bash
terraform destroy
```

## Variables requises

### Variables globales (variables.tf)

- `do_token`: Token API Digital Ocean (sensible)
- `project_name`: Nom du projet (défaut: "izzzi")
- `environment`: Environnement (staging, production, dev)
- `region`: Région Digital Ocean (fra1 ou ams3)
- `terraform_backend_bucket`: Nom du bucket Spaces pour le state
- `terraform_backend_region`: Région du bucket Spaces
- `terraform_backend_key`: Clé/path du state file
- `terraform_backend_endpoint`: Endpoint URL du bucket Spaces
- `common_tags`: Tags communs à appliquer aux ressources

### Variables par environnement

Chaque environnement (`envs/dev/` et `envs/prod/`) peut avoir ses propres variables spécifiques définies dans `variables.tf` et `terraform.tfvars`.

## Conventions de nommage

Toutes les ressources suivent la convention: `{project}-{environment}-{resource}`

Exemple: `izzzi-staging-droplet-frontend-01`

## Workspaces Terraform

Utilisez les workspaces Terraform pour gérer les différents environnements:

- `staging`: Environnement de staging
- `production`: Environnement de production

## Sécurité

- Toutes les variables sensibles sont marquées avec `sensitive = true`
- Le state Terraform est stocké dans un bucket Spaces chiffré
- Ne commitez jamais les fichiers `terraform.tfvars` contenant des valeurs réelles

## Modules

Les modules sont organisés par type de ressource:

- **networking**: Configuration réseau (VPC, etc.)
- **droplet**: Droplets pour les différents services
- **database**: Base de données PostgreSQL managée avec pgvector
- **spaces**: Buckets Spaces pour le stockage objet
- **firewall**: Règles de firewall
- **dns**: Enregistrements DNS

## Support

Pour toute question ou problème, consultez la documentation Digital Ocean ou ouvrez une issue.
