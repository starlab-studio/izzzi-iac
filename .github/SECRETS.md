# Configuration des Secrets GitHub Actions

Ce document explique comment configurer les secrets nécessaires pour le workflow Terraform CI/CD.

## Secrets requis

Le workflow Terraform nécessite **3 secrets** à configurer dans GitHub :

### 1. `DIGITALOCEAN_TOKEN`

**Description** : Token d'API DigitalOcean pour provisionner les ressources (droplets, VPC, firewalls, etc.)

**Comment l'obtenir** :

1. Connectez-vous à votre compte DigitalOcean : https://cloud.digitalocean.com
2. Allez dans **API** → **Tokens/Keys**
3. Cliquez sur **Generate New Token**
4. Donnez un nom au token (ex: `izzzi-terraform-github-actions`)
5. Sélectionnez les permissions : **Write** (pour créer/modifier les ressources)
6. Cliquez sur **Generate Token**
7. **Copiez le token immédiatement** (il ne sera plus visible après)

**Où le configurer dans GitHub** :

- Repository → Settings → Secrets and variables → Actions
- Cliquez sur **New repository secret**
- Name: `DIGITALOCEAN_TOKEN`
- Secret: Collez le token copié
- Cliquez sur **Add secret**

---

### 2. `SPACES_ACCESS_KEY_ID`

**Description** : Clé d'accès pour Digital Ocean Spaces (utilisé comme backend S3-compatible pour le state Terraform)

**Comment l'obtenir** :

1. Connectez-vous à votre compte DigitalOcean : https://cloud.digitalocean.com
2. Allez dans **API** → **Tokens/Keys**
3. Cliquez sur **Spaces Keys** (ou **Generate New Key** dans la section Spaces)
4. Cliquez sur **Generate New Key**
5. Donnez un nom à la clé (ex: `izzzi-terraform-spaces`)
6. **Copiez la clé d'accès (Access Key)** immédiatement

**Où le configurer dans GitHub** :

- Repository → Settings → Secrets and variables → Actions
- Cliquez sur **New repository secret**
- Name: `SPACES_ACCESS_KEY_ID`
- Secret: Collez la clé d'accès
- Cliquez sur **Add secret**

---

### 3. `SPACES_SECRET_KEY`

**Description** : Clé secrète pour Digital Ocean Spaces (utilisé comme backend S3-compatible pour le state Terraform)

**Comment l'obtenir** :

1. Dans la même page où vous avez créé la clé d'accès (voir ci-dessus)
2. **Copiez la clé secrète (Secret Key)** immédiatement (elle ne sera plus visible après)

**Où le configurer dans GitHub** :

- Repository → Settings → Secrets and variables → Actions
- Cliquez sur **New repository secret**
- Name: `SPACES_SECRET_KEY`
- Secret: Collez la clé secrète
- Cliquez sur **Add secret**

---

## Vérification

Une fois les 3 secrets configurés, vous pouvez vérifier qu'ils sont bien présents :

1. Allez dans **Repository → Settings → Secrets and variables → Actions**
2. Vous devriez voir les 3 secrets listés :
   - `DIGITALOCEAN_TOKEN`
   - `SPACES_ACCESS_KEY_ID`
   - `SPACES_SECRET_KEY`

## Prérequis Digital Ocean Spaces

Avant de configurer les secrets, assurez-vous que :

1. **Un Space existe** pour stocker le state Terraform :

   - Nom du bucket : `izzzi-terraform-state` (défini dans `terraform/envs/*/backend.tf`)
   - Région : `fra1` (Frankfurt) ou `ams3` (Amsterdam)
   - Visibilité : **Private** (recommandé pour la sécurité)

2. **Le Space est accessible** avec les clés générées

## Sécurité

- **Ne jamais** commiter ces secrets dans le code
- **Ne jamais** partager ces secrets publiquement
- Utiliser uniquement les secrets GitHub Actions
- Limiter les permissions des tokens au strict nécessaire
- Régénérer les tokens/clés régulièrement (tous les 90 jours recommandé)

## Dépannage

### Erreur : "Failed to initialize backend"

- Vérifiez que `SPACES_ACCESS_KEY_ID` et `SPACES_SECRET_KEY` sont correctement configurés
- Vérifiez que le Space `izzzi-terraform-state` existe dans la région `fra1`
- Vérifiez que les clés ont les permissions nécessaires

### Erreur : "Authentication failed"

- Vérifiez que `DIGITALOCEAN_TOKEN` est valide et n'a pas expiré
- Vérifiez que le token a les permissions **Write**

### Erreur : "Access Denied"

- Vérifiez que les clés Spaces ont accès au bucket `izzzi-terraform-state`
- Vérifiez que le Space n'est pas supprimé ou suspendu
