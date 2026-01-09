# IZZZI Ansible Automation

Playbooks et rôles Ansible pour automatiser le déploiement et la gestion de l'infrastructure IZZZI sur Docker Swarm.

## Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Prérequis](#prérequis)
- [Structure du projet](#structure-du-projet)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Playbooks disponibles](#playbooks-disponibles)
- [Rôles disponibles](#rôles-disponibles)
- [Variables](#variables)
- [Secrets Docker](#secrets-docker)
- [Troubleshooting](#troubleshooting)

## Vue d'ensemble

Cette infrastructure Ansible permet de :

- ✅ Configurer les nodes avec les packages système nécessaires
- ✅ Installer et configurer Docker sur tous les nodes
- ✅ Initialiser un cluster Docker Swarm
- ✅ Déployer la stack applicative IZZZI
- ✅ Gérer les backups PostgreSQL
- ✅ Effectuer des rollbacks de services
- ✅ Scaler les services dynamiquement

**Architecture simplifiée** :

- 1 PostgreSQL avec pgvector (schemas: `public` + `ai`)
- 1 Redis (DBs: 0=cache, 1=ai-cache, 2=celery-broker, 3=celery-results)
- Manager node avec label `db=true` héberge les bases de données

## Prérequis

### Logiciels requis

- Ansible >= 2.10
- Python >= 3.8
- SSH access aux nodes
- Terraform (pour provisionner l'infrastructure)

### Installation d'Ansible

**MacOS** :

```bash
brew install ansible
```

**Ubuntu/Debian** :

```bash
sudo apt update
sudo apt install ansible
```

**Python pip** :

```bash
pip3 install ansible
```

### Variables d'environnement

Créer un fichier `.env` ou exporter ces variables :

```bash
# Digital Ocean
export TF_VAR_do_token="your-do-token"

# Spaces (pour backups)
export SPACES_ACCESS_KEY="your-spaces-access-key"
export SPACES_SECRET_KEY="your-spaces-secret-key"

# Database
export DB_USER="izzzi_admin"
export DB_PASSWORD="super_secure_password"

# Application secrets
export JWT_SECRET="your-jwt-secret"
export JWT_REFRESH_SECRET="your-jwt-refresh-secret"
export OPENAI_API_KEY="sk-..."
export STRIPE_SECRET_KEY="sk_live_..."
export REDIS_PASSWORD="your-redis-password"
```

## Structure du projet

```
ansible/
├── ansible.cfg                 # Configuration Ansible
├── inventory/                  # Inventaires par environnement
│   ├── dev.yml                # Inventaire DEV/Staging
│   └── prod.yml               # Inventaire Production
├── group_vars/
│   └── all.yml                # Variables globales
├── roles/                     # Rôles Ansible
│   ├── common/                # Configuration système de base
│   ├── docker/                # Installation Docker
│   ├── swarm-manager/         # Initialisation Swarm manager
│   ├── swarm-worker/          # Join workers au Swarm
│   ├── deploy-stack/          # Déploiement de la stack
│   └── backup/                # Backup PostgreSQL
└── playbooks/                 # Playbooks principaux
    ├── site.yml               # Playbook complet
    ├── init-cluster.yml       # Initialisation cluster uniquement
    ├── deploy.yml             # Déploiement/mise à jour stack
    ├── backup.yml             # Backup database
    ├── rollback.yml           # Rollback service
    └── scale.yml              # Scaling de services
```

## Installation

1. **Cloner le projet** :

   ```bash
   cd izzzi-iac/ansible
   ```

2. **Vérifier l'installation d'Ansible** :

   ```bash
   ansible --version
   ```

3. **Tester la connexion SSH** :
   ```bash
   ansible all -i inventory/dev.yml -m ping
   ```

## Configuration

### 1. Configurer l'inventaire

Après avoir provisionné l'infrastructure avec Terraform, récupérer les IPs :

```bash
cd ../terraform/envs/dev
terraform output manager_ip
terraform output worker_ips
```

Mettre à jour `inventory/dev.yml` :

```yaml
all:
  children:
    managers:
      hosts:
        manager1:
          ansible_host: "203.0.113.10" # Remplacer par IP réelle
          private_ip: "10.10.0.5" # Remplacer par IP privée
    workers:
      hosts:
        worker1:
          ansible_host: "203.0.113.11"
          private_ip: "10.10.0.6"
```

### 2. Configurer la clé SSH

Copier votre clé SSH sur les nodes ou s'assurer qu'elle est déjà configurée (fait par Terraform/cloud-init).

### 3. Tester la connectivité

```bash
ansible all -i inventory/dev.yml -m ping
```

## Utilisation

### Avec Make (recommandé)

À la racine du projet `izzzi-iac/` :

```bash
# Afficher l'aide
make help

# Déploiement complet DEV
make full-deploy-dev

# Initialiser le cluster uniquement
make ansible-init-dev

# Déployer l'application
make ansible-deploy-dev

# Déployer avec un tag spécifique
make ansible-deploy-dev-tag TAG=v1.2.3

# Backup database
make ansible-backup-dev

# Rollback service
make ansible-rollback-dev SERVICE=frontend

# Scale service
make ansible-scale-dev SERVICE=backend REPLICAS=3
```

### Sans Make (commandes Ansible directes)

```bash
cd ansible

# Déploiement complet
ansible-playbook playbooks/site.yml -i inventory/dev.yml

# Initialiser le cluster
ansible-playbook playbooks/init-cluster.yml -i inventory/dev.yml

# Déployer la stack
ansible-playbook playbooks/deploy.yml -i inventory/dev.yml

# Déployer avec tag
ansible-playbook playbooks/deploy.yml -i inventory/dev.yml -e "image_tag=v1.2.3"

# Backup
ansible-playbook playbooks/backup.yml -i inventory/dev.yml

# Rollback
ansible-playbook playbooks/rollback.yml -i inventory/dev.yml -e "service=frontend"

# Scale
ansible-playbook playbooks/scale.yml -i inventory/dev.yml -e "service=backend replicas=3"
```

## Playbooks disponibles

### site.yml - Déploiement complet

Configure l'infrastructure complète et déploie l'application.

```bash
ansible-playbook playbooks/site.yml -i inventory/dev.yml
```

**Exécute** :

1. Rôle `common` sur tous les nodes
2. Rôle `docker` sur tous les nodes
3. Rôle `swarm-manager` sur le manager
4. Rôle `swarm-worker` sur les workers
5. Rôle `deploy-stack` sur le manager

### init-cluster.yml - Initialisation cluster

Initialise uniquement le cluster Docker Swarm (sans déployer l'application).

```bash
ansible-playbook playbooks/init-cluster.yml -i inventory/dev.yml
```

### deploy.yml - Déploiement/mise à jour

Déploie ou met à jour la stack applicative.

```bash
# Déployer avec image "latest"
ansible-playbook playbooks/deploy.yml -i inventory/dev.yml

# Déployer avec tag spécifique
ansible-playbook playbooks/deploy.yml -i inventory/dev.yml -e "image_tag=v1.2.3"

# Mettre à jour un service spécifique
ansible-playbook playbooks/deploy.yml -i inventory/dev.yml -e "service=backend image_tag=v1.2.4"
```

### backup.yml - Backup PostgreSQL

Sauvegarde la base de données PostgreSQL.

```bash
# Backup complet
ansible-playbook playbooks/backup.yml -i inventory/dev.yml

# Backup d'un schéma spécifique
ansible-playbook playbooks/backup.yml -i inventory/dev.yml -e "backup_schema=public"

# Backup sans upload vers Spaces
ansible-playbook playbooks/backup.yml -i inventory/dev.yml -e "upload_to_spaces=false"
```

### rollback.yml - Rollback service

Rollback un service à sa version précédente.

```bash
# Rollback un service spécifique
ansible-playbook playbooks/rollback.yml -i inventory/dev.yml -e "service=frontend"

# Rollback tous les services
ansible-playbook playbooks/rollback.yml -i inventory/dev.yml -e "service=all"
```

### scale.yml - Scaling de services

Scale le nombre de replicas d'un service.

```bash
# Scale un service
ansible-playbook playbooks/scale.yml -i inventory/dev.yml -e "service=backend replicas=3"
```

## Rôles disponibles

### common

Configure les paramètres système de base :

- Mise à jour système
- Installation de packages
- Configuration timezone
- Configuration UFW firewall
- Création utilisateur deploy

### docker

Installe et configure Docker :

- Installation Docker CE
- Configuration daemon Docker
- Ajout utilisateur au groupe docker

### swarm-manager

Initialise Docker Swarm sur le manager :

- Initialisation Swarm
- Génération des tokens
- Label `db=true` sur le manager
- Création du network overlay

### swarm-worker

Joint les workers au Swarm :

- Join avec le token manager
- Vérification de l'état

### deploy-stack

Déploie la stack applicative :

- Template docker-stack.yml
- Template .env
- Création des secrets Docker
- Déploiement via `docker stack deploy`

### backup

Backup PostgreSQL :

- Dump PostgreSQL
- Compression gzip
- Upload vers Spaces (optionnel)
- Nettoyage des anciens backups

## Variables

### Variables globales (group_vars/all.yml)

| Variable                | Description                | Défaut          |
| ----------------------- | -------------------------- | --------------- |
| `docker_version`        | Version de Docker          | `latest`        |
| `swarm_network_name`    | Nom du network Swarm       | `izzzi-network` |
| `stack_name`            | Nom de la stack            | `izzzi`         |
| `database_name`         | Nom de la database         | `izzzi`         |
| `backup_retention_days` | Jours de rétention backups | `7`             |
| `replicas.frontend`     | Replicas frontend          | `1`             |
| `replicas.backend`      | Replicas backend           | `2`             |
| `replicas.ai_api`       | Replicas AI API            | `1`             |

### Variables d'inventaire

Définies dans `inventory/dev.yml` ou `inventory/prod.yml` :

| Variable        | Description                         |
| --------------- | ----------------------------------- |
| `environment`   | Environnement (dev, production)     |
| `domain`        | Domaine de l'application            |
| `database_host` | Host PostgreSQL (IP privée manager) |
| `redis_host`    | Host Redis (IP privée manager)      |

## Secrets Docker

Les secrets Docker sont créés automatiquement lors du déploiement. Liste des secrets requis :

- `db_user` - Utilisateur PostgreSQL
- `db_password` - Mot de passe PostgreSQL
- `jwt_secret` - Secret JWT
- `jwt_refresh_secret` - Secret JWT refresh
- `openai_api_key` - Clé API OpenAI
- `stripe_secret_key` - Clé secrète Stripe
- `stripe_webhook_secret` - Secret webhook Stripe
- `google_client_secret` - Secret client Google
- `brevo_api_key` - Clé API Brevo
- `aws_secret_access_key` - Clé secrète AWS
- `cognito_client_secret` - Secret client Cognito
- `spaces_access_key` - Clé d'accès Spaces
- `spaces_secret_key` - Clé secrète Spaces

Les secrets sont récupérés depuis les variables d'environnement au moment du déploiement.

## Troubleshooting

### Ansible ne peut pas se connecter aux nodes

**Erreur** : `Failed to connect to the host via ssh`

**Solution** :

1. Vérifier que la clé SSH est correcte :
   ```bash
   ssh deploy@<manager_ip>
   ```
2. Vérifier le chemin de la clé dans l'inventaire
3. Vérifier que le pare-feu autorise SSH

### Swarm déjà initialisé

**Erreur** : `This node is already part of a swarm`

**Solution** : Normal si le cluster existe déjà. Utiliser `deploy.yml` pour déployer/mettre à jour.

### Secrets déjà existants

**Erreur** : `Error response from daemon: secret already exists`

**Solution** : Normal, les secrets existants sont réutilisés. Pour recréer :

```bash
docker secret rm <secret_name>
```

### Service ne démarre pas

**Vérifier les logs** :

```bash
docker service logs izzzi_<service_name>
docker service ps izzzi_<service_name>
```

### Backup échoue

**Vérifier** :

1. Container PostgreSQL en cours d'exécution
2. Credentials DB corrects
3. Espace disque disponible
4. Pour upload Spaces : credentials corrects

## Bonnes pratiques

### Sécurité

1. **Ne jamais commiter de secrets** dans Git
2. **Utiliser ansible-vault** pour chiffrer les variables sensibles (optionnel)
3. **Restreindre l'accès SSH** aux IPs autorisées
4. **Changer les mots de passe par défaut**

### Déploiement

1. **Tester en DEV** avant production
2. **Utiliser des tags** d'image spécifiques en production
3. **Faire des backups** avant mise à jour
4. **Vérifier les logs** après déploiement

### Maintenance

1. **Backups réguliers** (automatiser via cron)
2. **Monitoring** des services
3. **Nettoyer les anciennes images** Docker
4. **Mettre à jour les packages** système

## Workflow de déploiement complet

1. **Provisionner l'infrastructure avec Terraform** :

   ```bash
   cd terraform/envs/dev
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

2. **Récupérer les IPs et mettre à jour l'inventaire Ansible** :

   ```bash
   terraform output manager_ip
   terraform output worker_ips
   # Mettre à jour ansible/inventory/dev.yml
   ```

3. **Initialiser le cluster Docker Swarm** :

   ```bash
   cd ../../ansible
   ansible-playbook playbooks/init-cluster.yml -i inventory/dev.yml
   ```

4. **Déployer l'application** :

   ```bash
   ansible-playbook playbooks/deploy.yml -i inventory/dev.yml
   ```

5. **Vérifier le déploiement** :
   ```bash
   ssh deploy@<manager_ip>
   docker stack services izzzi
   docker stack ps izzzi
   ```

## Support

Pour toute question ou problème :

1. Consulter la documentation Ansible
2. Vérifier les logs Docker
3. Consulter le README principal du projet
