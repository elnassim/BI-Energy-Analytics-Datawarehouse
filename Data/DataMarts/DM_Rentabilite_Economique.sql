-- ============================================================
-- Data Mart 2: Rentabilité Économique
-- Architecture en Étoile (Star Schema)
-- ============================================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS DM_Rentabilite_Economique;
USE DM_Rentabilite_Economique;

-- ============================================================
-- TABLES DE DIMENSIONS
-- ============================================================

-- Dimension Temps
CREATE TABLE IF NOT EXISTS Dim_Temps (
    id_temps INT PRIMARY KEY AUTO_INCREMENT,
    date_complete DATE NOT NULL,
    annee INT NOT NULL,
    mois INT NOT NULL,
    nom_mois VARCHAR(20),
    trimestre INT,
    semestre INT,
    semaine INT,
    jour INT,
    jour_semaine VARCHAR(20),
    est_weekend BOOLEAN,
    periode_fiscale VARCHAR(20), -- Q1, Q2, Q3, Q4
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (date_complete)
) ENGINE=InnoDB;

-- Dimension Client
CREATE TABLE IF NOT EXISTS Dim_Client (
    id_client INT PRIMARY KEY AUTO_INCREMENT,
    code_client VARCHAR(50) UNIQUE NOT NULL,
    nom_client VARCHAR(100) NOT NULL,
    type_client VARCHAR(50), -- Résidentiel, Commercial, Industriel
    segment_client VARCHAR(50), -- Premium, Standard, Économique
    adresse VARCHAR(255),
    ville VARCHAR(100),
    pays VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100),
    date_inscription DATE,
    score_credit INT, -- 1-100
    statut_client VARCHAR(20), -- Actif, Inactif, Suspendu
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Bâtiment
CREATE TABLE IF NOT EXISTS Dim_Batiment (
    id_batiment INT PRIMARY KEY AUTO_INCREMENT,
    code_batiment VARCHAR(50) UNIQUE NOT NULL,
    nom_batiment VARCHAR(100) NOT NULL,
    type_batiment VARCHAR(50), -- Bureau, Résidentiel, Commercial, Industriel
    surface_m2 DECIMAL(10,2),
    valeur_estimee DECIMAL(15,2), -- Valeur du bâtiment
    adresse VARCHAR(255),
    ville VARCHAR(100),
    code_postal VARCHAR(20),
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Région (Site)
CREATE TABLE IF NOT EXISTS Dim_Region (
    id_region INT PRIMARY KEY AUTO_INCREMENT,
    code_region VARCHAR(50) UNIQUE NOT NULL,
    nom_region VARCHAR(100) NOT NULL,
    pays VARCHAR(100),
    zone_economique VARCHAR(50),
    taux_taxe DECIMAL(5,4), -- Taux de taxe local
    responsable VARCHAR(100),
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Type Énergie
CREATE TABLE IF NOT EXISTS Dim_Type_Energie (
    id_type_energie INT PRIMARY KEY AUTO_INCREMENT,
    code_type_energie VARCHAR(50) UNIQUE NOT NULL,
    nom_type_energie VARCHAR(50) NOT NULL, -- Électricité, Eau, Gaz
    unite_mesure VARCHAR(20) NOT NULL, -- kWh, m3
    cout_unitaire_moyen DECIMAL(10,4),
    prix_vente_unitaire DECIMAL(10,4),
    marge_unitaire DECIMAL(10,4),
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Facture
CREATE TABLE IF NOT EXISTS Dim_Facture (
    id_facture INT PRIMARY KEY AUTO_INCREMENT,
    numero_facture VARCHAR(50) UNIQUE NOT NULL,
    type_facture VARCHAR(50), -- Régulière, Ajustement, Relance
    mode_paiement VARCHAR(50), -- Virement, Carte, Chèque, Prélèvement
    delai_paiement INT, -- Nombre de jours
    statut_facture VARCHAR(20), -- Émise, Payée, En retard, Annulée
    date_emission DATE,
    date_echeance DATE,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Paiement
CREATE TABLE IF NOT EXISTS Dim_Paiement (
    id_paiement INT PRIMARY KEY AUTO_INCREMENT,
    numero_paiement VARCHAR(50) UNIQUE NOT NULL,
    mode_paiement VARCHAR(50), -- Virement, Carte, Chèque, Prélèvement
    statut_paiement VARCHAR(20), -- Reçu, En attente, Rejeté, Remboursé
    date_paiement DATE,
    delai_recouvrement INT, -- Jours entre facture et paiement
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- TABLE DE FAITS
-- ============================================================

CREATE TABLE IF NOT EXISTS Fait_Rentabilite (
    id_fait_rentabilite BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Clés étrangères vers les dimensions
    id_temps INT NOT NULL,
    id_client INT NOT NULL,
    id_batiment INT NOT NULL,
    id_region INT NOT NULL,
    id_type_energie INT NOT NULL,
    id_facture INT NOT NULL,
    id_paiement INT,

    -- Mesures Financières (Faits)
    quantite_energie DECIMAL(15,4) NOT NULL, -- Quantité d'énergie facturée
    montant_ht DECIMAL(15,2) NOT NULL, -- Montant Hors Taxe
    montant_tva DECIMAL(15,2) NOT NULL, -- Montant de la TVA
    montant_ttc DECIMAL(15,2) NOT NULL, -- Montant Toutes Taxes Comprises
    cout_energie DECIMAL(15,2) NOT NULL, -- Coût d'achat de l'énergie

    -- KPI Calculés
    marge_brute DECIMAL(15,2), -- montant_ttc - cout_energie
    taux_marge DECIMAL(5,4), -- (marge_brute / montant_ttc) * 100
    montant_paye DECIMAL(15,2) DEFAULT 0, -- Montant effectivement payé
    montant_impaye DECIMAL(15,2), -- montant_ttc - montant_paye
    taux_recouvrement DECIMAL(5,4), -- (montant_paye / montant_ttc) * 100

    -- Indicateurs de Performance
    revenu_par_kwh DECIMAL(10,4), -- montant_ttc / quantite_energie
    cout_par_kwh DECIMAL(10,4), -- cout_energie / quantite_energie

    -- Délais
    jours_paiement INT, -- Délai entre émission et paiement
    est_en_retard BOOLEAN, -- Si paiement en retard
    jours_retard INT, -- Nombre de jours de retard

    -- Métadonnées
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Contraintes de clés étrangères
    FOREIGN KEY (id_temps) REFERENCES Dim_Temps(id_temps),
    FOREIGN KEY (id_client) REFERENCES Dim_Client(id_client),
    FOREIGN KEY (id_batiment) REFERENCES Dim_Batiment(id_batiment),
    FOREIGN KEY (id_region) REFERENCES Dim_Region(id_region),
    FOREIGN KEY (id_type_energie) REFERENCES Dim_Type_Energie(id_type_energie),
    FOREIGN KEY (id_facture) REFERENCES Dim_Facture(id_facture),
    FOREIGN KEY (id_paiement) REFERENCES Dim_Paiement(id_paiement),

    -- Index pour optimiser les requêtes
    INDEX idx_temps (id_temps),
    INDEX idx_client (id_client),
    INDEX idx_batiment (id_batiment),
    INDEX idx_region (id_region),
    INDEX idx_type_energie (id_type_energie),
    INDEX idx_facture (id_facture),
    INDEX idx_date_ajout (date_ajout)
) ENGINE=InnoDB;

-- ============================================================
-- VUES POUR L'ANALYSE
-- ============================================================

-- Vue: Chiffre d'affaires par client
CREATE OR REPLACE VIEW V_CA_Par_Client AS
SELECT
    dc.code_client,
    dc.nom_client,
    dc.type_client,
    dt.annee,
    dt.trimestre,
    SUM(fr.montant_ttc) AS chiffre_affaires,
    SUM(fr.marge_brute) AS marge_totale,
    AVG(fr.taux_marge) AS taux_marge_moyen,
    SUM(fr.montant_paye) AS montant_recouvre,
    AVG(fr.taux_recouvrement) AS taux_recouvrement_moyen
FROM Fait_Rentabilite fr
JOIN Dim_Client dc ON fr.id_client = dc.id_client
JOIN Dim_Temps dt ON fr.id_temps = dt.id_temps
GROUP BY dc.code_client, dc.nom_client, dc.type_client, dt.annee, dt.trimestre;

-- Vue: Rentabilité par région
CREATE OR REPLACE VIEW V_Rentabilite_Par_Region AS
SELECT
    dr.code_region,
    dr.nom_region,
    dt.annee,
    dt.mois,
    SUM(fr.montant_ttc) AS chiffre_affaires,
    SUM(fr.cout_energie) AS cout_total,
    SUM(fr.marge_brute) AS marge_totale,
    AVG(fr.taux_marge) AS taux_marge_moyen,
    COUNT(DISTINCT fr.id_client) AS nombre_clients
FROM Fait_Rentabilite fr
JOIN Dim_Region dr ON fr.id_region = dr.id_region
JOIN Dim_Temps dt ON fr.id_temps = dt.id_temps
GROUP BY dr.code_region, dr.nom_region, dt.annee, dt.mois;

-- Vue: Rentabilité par type d'énergie
CREATE OR REPLACE VIEW V_Rentabilite_Par_Type_Energie AS
SELECT
    dte.nom_type_energie,
    dt.annee,
    dt.trimestre,
    SUM(fr.quantite_energie) AS quantite_totale,
    SUM(fr.montant_ttc) AS chiffre_affaires,
    SUM(fr.cout_energie) AS cout_total,
    SUM(fr.marge_brute) AS marge_totale,
    AVG(fr.taux_marge) AS taux_marge_moyen
FROM Fait_Rentabilite fr
JOIN Dim_Type_Energie dte ON fr.id_type_energie = dte.id_type_energie
JOIN Dim_Temps dt ON fr.id_temps = dt.id_temps
GROUP BY dte.nom_type_energie, dt.annee, dt.trimestre;

-- Vue: Top clients les plus rentables
CREATE OR REPLACE VIEW V_Top_Clients_Rentables AS
SELECT
    dc.code_client,
    dc.nom_client,
    dc.type_client,
    SUM(fr.montant_ttc) AS chiffre_affaires_total,
    SUM(fr.marge_brute) AS marge_totale,
    AVG(fr.taux_marge) AS taux_marge_moyen,
    AVG(fr.taux_recouvrement) AS taux_recouvrement_moyen,
    COUNT(fr.id_fait_rentabilite) AS nombre_factures
FROM Fait_Rentabilite fr
JOIN Dim_Client dc ON fr.id_client = dc.id_client
GROUP BY dc.code_client, dc.nom_client, dc.type_client
ORDER BY marge_totale DESC;

-- Vue: Analyse des retards de paiement
CREATE OR REPLACE VIEW V_Analyse_Retards AS
SELECT
    dt.annee,
    dt.mois,
    COUNT(CASE WHEN fr.est_en_retard = TRUE THEN 1 END) AS nombre_retards,
    COUNT(fr.id_fait_rentabilite) AS nombre_total_factures,
    (COUNT(CASE WHEN fr.est_en_retard = TRUE THEN 1 END) / COUNT(fr.id_fait_rentabilite)) * 100 AS taux_retard,
    AVG(fr.jours_retard) AS jours_retard_moyen,
    SUM(CASE WHEN fr.est_en_retard = TRUE THEN fr.montant_ttc ELSE 0 END) AS montant_en_retard
FROM Fait_Rentabilite fr
JOIN Dim_Temps dt ON fr.id_temps = dt.id_temps
GROUP BY dt.annee, dt.mois;
