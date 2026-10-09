# 🛡️ AWS Cloud Security & DevSecOps Lab

![Terraform SecOps Pipeline](https://github.com/issamneji2003/aws-cloud-security-lab/actions/workflows/terraform.yml/badge.svg)
![Checkov Compliance](https://img.shields.io/badge/checkov-passed-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

Laboratoire professionnel de sécurité cloud, d'infrastructure as code (IaC) sécurisée, de conformité continue et d'auto-remédiation sur AWS.

---

## 📑 Sommaire
1. [Vue d'ensemble du projet](#-vue-densemble-du-projet)
2. [Architecture & Composants Sécurisés](#-architecture--composants-sécurisés)
3. [Pipeline CI/CD & DevSecOps](#-pipeline-cicd--devsecops)
4. [Documentation & Guides du Lab](#-documentation--guides-du-lab)
5. [Auto-Remédiation](#-auto-remédiation)
6. [Modélisation des Menaces (Threat Modeling)](docs/threat-modeling.md)

---

## 🎯 Vue d'ensemble du projet
Ce dépôt démontre une démarche complète de sécurisation d'une infrastructure cloud AWS en suivant les meilleures pratiques du secteur (CIS Benchmarks, Zero Trust) :
- **Infrastructure as Code (IaC)** avec Terraform.
- **Sécurité intégrée (Shift-Left)** via des analyses statiques automatisées (Checkov) dans GitHub Actions.
- **Surveillance continue** via AWS Config.
- **Réponse automatisée** aux incidents de configuration.

---

## 🏗️ Architecture & Composants Sécurisés
* **Amazon S3** : Chiffrement côté serveur (AES-256), versioning actif, blocage strict des accès publics, journalisation (access logging) et politiques d'obligation HTTPS (`aws:SecureTransport`).
* **Amazon EC2 & Réseau** : Instance durcie avec exigence stricte de l'**IMDSv2** (protection contre les SSRF), chiffrement des volumes EBS par défaut, et groupes de sécurité au moindre privilège (SSH restreint à une IP de confiance).
* **AWS Config** : Enregistreur et règles d'audit permanent de la conformité des ressources.

---

## 🚀 Pipeline CI/CD & DevSecOps
Chaque modification du code Terraform déclenche un pipeline GitHub Actions automatisé qui exécute :
1. `terraform init` / `validate` / `plan`
2. **Checkov** pour le scan de vulnérabilités et de conformité de l'IaC.

---

## 📚 Documentation & Guides du Lab
Retrouvez l'ensemble des détails et preuves dans le dossier `docs/` :
* [Guide Étape par Étape du Lab](docs/guide-etape-par-etape.md)
* [Rapport de Preuves & Tests](docs/test-evidence.md)
* [Guide de Remédiation](docs/remediation-guide.md)

---

## 🛡️ Auto-Remédiation
Un script de réponse automatisée (`remediation/auto_remediate_s3.py`) est intégré pour détecter et corriger instantanément toute dérive de configuration critique sur les compartiments S3.