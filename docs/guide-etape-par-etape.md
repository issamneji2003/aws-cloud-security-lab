# Guide Détaillé : Secure Cloud Lab & Remédiation sur AWS Free Tier

Ce guide détaille la mise en place, les erreurs intentionnelles et la remédiation de notre laboratoire de sécurité cloud sur AWS.

## Phase 1 : Création de l'Environnement Vulnérable (By Design)

### 1.1 Configuration du Stockage (Amazon S3)
- **Création du Compartiment** :
  - Rendez-vous dans le service Amazon S3 de la console AWS.
  - Cliquez sur *Créer un compartiment*.
  - Nommez votre compartiment (ex: `mon-lab-securite-s3-issamneji`) dans la région `eu-north-1`.
- **Introduction de la vulnérabilité** :
  - Désactivez temporairement l'option *Bloquer tout accès public*.
  - Téléchargez un fichier sensible fictif nommé `secret.txt`.
  - Modifiez les permissions pour rendre l'objet accessible en lecture publique.

### 1.2 Déploiement du Serveur (Amazon EC2)
- **Lancement de l'instance** :
  - Rendez-vous dans `EC2` → `Lancer des instances`.
  - Nommez votre instance `serveur-vulnerable`.
  - Choisissez une image éligible au Free Tier (`t2.micro` ou `t3.micro`).
  - Créez et téléchargez une paire de clés SSH.
- **Introduction de la vulnérabilité réseau (Groupe de Sécurité)** :
  - Créez une règle entrante pour le protocole SSH (Port 22) en définissant la source sur N'importe où (`0.0.0.0/0`).

---

## Phase 2 : Sécurisation et Durcissement (Hardening)

### 2.1 Sécurisation du Stockage S3
- **Activation du Blocage Public** : Cochez *Bloquer tout accès public* dans l'onglet Autorisations.
- **Chiffrement et Versioning** : Activez le chiffrement par défaut `SSE-S3` et la Gestion des versions.

### 2.2 Sécurisation Réseau de l'Instance EC2
- **Restriction du Groupe de Sécurité** : Remplacez la source `0.0.0.0/0` par ton IP de confiance (ex: `YOUR_PUBLIC_IP/32`) pour le port SSH[cite: 4].

### 2.3 Mise en Place de la Journalisation (CloudTrail)
- Créez un journal de suivi (Trail) nommé `mon-lab-trail` associé à un compartiment S3 pour enregistrer les événements de gestion.

---

## Phase 3 : Audit et Vérification via AWS CloudShell
Ouvrez le terminal CloudShell et exécutez la commande suivante pour vérifier la configuration S3 :
```bash
aws s3api get-public-access-block --bucket mon-lab-securite-s3-issamneji