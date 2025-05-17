# Projet Décisionnel Olist : Analyse des Performances Commerciales

## Résumé du Projet

Ce projet met en œuvre un système décisionnel complet pour analyser les performances commerciales de la marketplace brésilienne Olist. Il couvre l'ensemble du cycle de vie des données, depuis l'extraction de données brutes (fichiers CSV Olist et une source externe pour les fournisseurs) jusqu'à la création de tableaux de bord interactifs avec Power BI, en passant par la construction d'un Data Warehouse sur SQL Server et le développement d'un processus ETL robuste avec SSIS.

L'objectif est de transformer des données transactionnelles complexes en informations claires et exploitables pour la prise de décision, en se concentrant sur les ventes, les produits, les clients (par localisation), les avis, les paiements et les fournisseurs.

**Technologies Clés Utilisées :**
*   **Base de Données :** Microsoft SQL Server
*   **ETL :** SQL Server Integration Services (SSIS)
*   **Visualisation :** Microsoft Power BI
*   **Gestion :** SQL Server Management Studio (SSMS)
*   **Développement SSIS :** Visual Studio avec SQL Server Data Tools (SSDT)

---

## Architecture du Data Warehouse

Le Data Warehouse est modélisé selon un schéma en étoile simplifié, optimisé pour les requêtes analytiques.

![Schéma du Data Warehouse](Data/images/image%20(10).png)
*(Légende : Schéma en étoile final du Data Warehouse OlistDW)*

**Principales Tables :**
*   **`FactOrderItems` :** Table de faits centrale contenant les mesures de vente au niveau de chaque article commandé.
*   **`DimDate` :** Dimension temporelle (Année, Mois).
*   **`DimProduct` :** Informations sur les produits, incluant un lien vers `DimFournisseur`.
*   **`DimLocalisation` :** Localisation des commandes (basée sur City/State du client).
*   **`DimOrderStatus` :** Statuts des commandes.
*   **`DimPaymentType` :** Types de paiement.
*   **`DimReview` :** Scores des avis clients.
*   **`DimFournisseur` :** Informations sur les fournisseurs des produits.
*   **`Staging_OrderInfo` :** Table intermédiaire ETL pour pré-agréger les informations par commande.

---

## Tableaux de Bord Power BI : Synthèse Stratégique

Le Data Warehouse peuplé par le processus ETL alimente les tableaux de bord Power BI suivants, offrant une synthèse visuelle des performances commerciales :

![Dashboard Olist - Vue d'Ensemble Opérations et Paiements](Data/images/image%20(27).png)
*(Légende : Vue d'Ensemble Stratégique - Opérations, Paiements, et Tendances de Livraison)*

![Dashboard Olist - Analyse des Avis Clients](Data/images/image%20(26).png)
*(Légende : Analyse détaillée de la Satisfaction Client et répartition des scores d'avis)*

![Dashboard Olist - Analyse par Marché](Data/images/image%20(25).png)
*(Légende : Performances des Ventes par État et analyse géographique du CA et des Quantités)*

![Dashboard Olist - Analyse Produits](Data/images/image%20(24).png)
*(Légende : Analyse des Produits, incluant les KPIs produits, tendances de vente et top produits)*

![Dashboard Olist - Vue d'Ensemble KPIs et Tendances Annuelles](Data/images/image%20(23).png)
*(Légende : KPIs Généraux de Performance et Tendances Annuelles/Saisonnières des Ventes)*

**Analyses Clés Permises :**
*   **Performance Globale :** Suivi du Chiffre d'Affaires, Quantité Vendue, Coût de Fret, Taux de Livraison et d'Annulation.
*   **Tendances Temporelles :** Évolution des ventes par année, saison et mois.
*   **Performance Produits & Fournisseurs :** Identification des produits et fournisseurs clés.
*   **Analyse Géographique :** Répartition des ventes et satisfaction client par État.
*   **Satisfaction Client :** Suivi de la moyenne des avis et répartition des notes.
*   **Efficacité Opérationnelle :** Analyse du flux des commandes et performance par type de paiement.

---

## Processus ETL (SSIS)

Un package SSIS unique (`ETL.dtsx`) a été développé pour orchestrer l'ensemble du flux de données, de la préparation des tables cibles (vidage et gestion des contraintes), au chargement des dimensions et de la table de staging, jusqu'au remplissage final de la table de faits. Ce package est conçu pour être déployé sur un Catalogue SSIS et automatisé via un Job SQL Server Agent.

*(Vous pouvez ajouter ici l'image de votre Control Flow SSIS si vous le souhaitez, en utilisant le même format de chemin)*
![Control Flow ETL SSIS](Data/images/image%20(8).png)

---

## Pour Commencer / Structure du Dépôt

*   **`/Data/SQLQuery`**: Contient les scripts T-SQL pour la création des tables du Data Warehouse.
*   **`/SSIS Brazilian E-Commerce Dataset/`**: Contient le projet SSIS (`.dtproj`) et le package `ETL.dtsx`.
*   **`/Olist E-commerce brésilien/`**: est le fichier `.pbix` du rapport Power BI.
*   **`/Data/*.csv`**:  contient les fichiers CSV Olist.
*   **`OlistDW`**:  est le fichier back de Data warehouse Olist.
---
