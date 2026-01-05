# Networking Module

Module Terraform pour créer et gérer un VPC (Virtual Private Cloud) sur Digital Ocean.

## Description

Ce module crée un VPC privé pour isoler l'infrastructure de l'application IZZZI. Le VPC permet de sécuriser et d'organiser les ressources réseau dans un environnement isolé.

## Utilisation

```hcl
module "networking" {
  source = "../../modules/networking"

  project_name = "izzzi"
  environment  = "staging"
  region       = "fra1"
  vpc_cidr     = "10.10.0.0/16"

  common_tags = {
    Project     = "izzzi"
    ManagedBy   = "terraform"
    Environment = "staging"
  }
}
```

## Variables

| Nom            | Type          | Description                                         | Défaut           | Requis |
| -------------- | ------------- | --------------------------------------------------- | ---------------- | ------ |
| `project_name` | `string`      | Nom du projet (utilisé pour le nommage et les tags) | -                | Oui    |
| `environment`  | `string`      | Nom de l'environnement (staging, production, dev)   | -                | Oui    |
| `region`       | `string`      | Région Digital Ocean (fra1 ou ams3)                 | -                | Oui    |
| `vpc_cidr`     | `string`      | CIDR block du VPC                                   | `"10.10.0.0/16"` | Non    |
| `common_tags`  | `map(string)` | Tags communs à appliquer aux ressources             | `{}`             | Non    |

## Outputs

| Nom          | Description                        |
| ------------ | ---------------------------------- |
| `vpc_id`     | ID du VPC créé                     |
| `vpc_urn`    | URN (Uniform Resource Name) du VPC |
| `vpc_cidr`   | CIDR block du VPC                  |
| `vpc_name`   | Nom du VPC créé                    |
| `vpc_region` | Région où le VPC est déployé       |

## Exemple d'utilisation des outputs

```hcl
# Utiliser l'ID du VPC dans d'autres modules
module "droplet" {
  source = "../../modules/droplet"

  vpc_id = module.networking.vpc_id
  # ...
}
```

## Conventions de nommage

Le VPC suit la convention de nommage: `{project_name}-{environment}-vpc`

Exemple: `izzzi-staging-vpc`

## Lifecycle

Le module utilise les règles de lifecycle suivantes:

- `create_before_destroy = true`: Crée la nouvelle ressource avant de détruire l'ancienne pour éviter les interruptions
- `prevent_destroy = false`: Permet la destruction de la ressource si nécessaire

## Tags

Le module applique automatiquement les tags suivants:

- `Name`: Nom du VPC
- `Component`: "networking"
- `Resource`: "vpc"
- Tags additionnels fournis via `common_tags`

## Notes

- Le CIDR block doit être valide et ne pas chevaucher d'autres réseaux existants
- Une fois créé, le CIDR block d'un VPC ne peut pas être modifié
- Le VPC est spécifique à une région et ne peut pas être déplacé entre régions
