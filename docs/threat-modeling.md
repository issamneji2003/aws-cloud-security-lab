\# 🔍 Architecture \& Modélisation des Menaces (Threat Modeling)



Ce document formalise l'analyse de risques menée en amont lors de la conception du laboratoire, détaillant les vecteurs de menaces identifiés et les mesures d'atténuation intégrées dans l'infrastructure Terraform.



\---



\## 1. Matrice des Menaces et Atténuations



| ID de la Menace | Composant Cible | Description du Risque (Vecteur d'attaque) | Mesure d'Atténuation Terraform \& Code |

| :--- | :--- | :--- | :--- |

| \*\*THR-01\*\* | \*\*Amazon S3\*\* | \*\*Exfiltration de données\*\* : Un compartiment S3 configuré par erreur avec des ACLs ou des politiques publiques permet à n'importe quel tiers sur Internet de lire ou lister les objets sensibles. | • Activation stricte de `block\_public\_acls`, `ignore\_public\_acls`, `block\_public\_policy` et `restrict\_public\_buckets`.<br>• Obligation du protocole HTTPS via la politique IAM `aws:SecureTransport`. |

| \*\*THR-02\*\* | \*\*Amazon EC2\*\* | \*\*Vol de métadonnées (SSRF)\*\* : Une faille de type \*Server-Side Request Forgery\* (SSRF) sur l'application hébergée permet d'interroger l'API de métadonnées (`http://169.254.169.254/`) pour voler les credentials temporaires du rôle IAM attaché à l'instance. | • Exigence stricte de l'\*\*IMDSv2\*\* (`http\_tokens = required` et désactivation de l'IMDSv1), imposant un jeton de session cryptographique pour toute requête aux métadonnées. |

| \*\*THR-03\*\* | \*\*Réseau (Security Group)\*\* | \*\*Accès non autorisé / Brute-force SSH\*\* : Exposition du port d'administration SSH (22) au monde entier (`0.0.0.0/0`), permettant des attaques massives de force brute par des bots. | • Restriction stricte des règles entrantes du Security Group à une seule adresse IP de confiance (`/32`).<br>• Isolation des flux sortants superflus. |

| \*\*THR-04\*\* | \*\*Configuration Globale\*\* | \*\*Dérive de configuration silencieuse (Configuration Drift)\*\* : Modification manuelle non tracée des paramètres de sécurité directement depuis la console AWS par un opérateur. | • Déploiement d'\*\*AWS Config\*\* couplé à un enregistreur permanent et à des scans continus via le pipeline CI/CD Checkov pour détecter et réaligner l'infrastructure. |



\---



\## 2. Principes de Sécurité Appliqués (Defense-in-Depth)

\- \*\*Moindre Privilège (Least Privilege)\*\* : Les rôles IAM et les groupes de sécurité n'accordent que les droits strictement nécessaires au fonctionnement minimal des services.

\- \*\*Sécurité dès la conception (Shift-Left)\*\* : L'ensemble des règles de conformité est validé avant même le déploiement cloud grâce aux scans statiques automatisés du code Terraform.

