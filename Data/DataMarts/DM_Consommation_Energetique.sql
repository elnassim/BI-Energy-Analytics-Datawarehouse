-- ============================================================
-- Data Mart 1: Consommation Énergétique
-- Architecture en Étoile (Star Schema)
-- ============================================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS DM_Consommation_Energetique;
USE DM_Consommation_Energetique;

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
    semaine INT,
    jour INT,
    jour_semaine VARCHAR(20),
    est_weekend BOOLEAN,
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
    adresse VARCHAR(255),
    ville VARCHAR(100),
    pays VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100),
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
    nombre_etages INT,
    annee_construction INT,
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
    zone_climatique VARCHAR(50),
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
    cout_unitaire DECIMAL(10,4),
    description VARCHAR(255),
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Compteur
CREATE TABLE IF NOT EXISTS Dim_Compteur (
    id_compteur INT PRIMARY KEY AUTO_INCREMENT,
    code_compteur VARCHAR(50) UNIQUE NOT NULL,
    type_compteur VARCHAR(50), -- Smart, Analogique, Numérique
    modele VARCHAR(100),
    date_installation DATE,
    statut VARCHAR(20), -- Actif, Inactif, Maintenance
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Météo
CREATE TABLE IF NOT EXISTS Dim_Meteo (
    id_meteo INT PRIMARY KEY AUTO_INCREMENT,
    temperature_moyenne DECIMAL(5,2),
    temperature_min DECIMAL(5,2),
    temperature_max DECIMAL(5,2),
    humidite DECIMAL(5,2),
    conditions VARCHAR(50), -- Ensoleillé, Nuageux, Pluvieux
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- TABLE DE FAITS
-- ============================================================

CREATE TABLE IF NOT EXISTS Fait_Consommation (
    id_fait_consommation BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Clés étrangères vers les dimensions
    id_temps INT NOT NULL,
    id_client INT NOT NULL,
    id_batiment INT NOT NULL,
    id_region INT NOT NULL,
    id_type_energie INT NOT NULL,
    id_compteur INT NOT NULL,
    id_meteo INT,

    -- Mesures (Faits)
    consommation_quantite DECIMAL(15,4) NOT NULL, -- Quantité consommée
    consommation_kwh_equivalente DECIMAL(15,4), -- Conversion en kWh pour comparaison
    cout_energie DECIMAL(15,2), -- Coût de la consommation
    heure_mesure TIME, -- Heure précise de la mesure
    periode_mesure VARCHAR(20), -- Matin, Après-midi, Soir, Nuit

    -- KPI calculés
    consommation_par_m2 DECIMAL(10,4), -- Consommation par surface
    variation_jour_precedent DECIMAL(10,2), -- % variation vs jour précédent
    variation_mois_precedent DECIMAL(10,2), -- % variation vs mois précédent

    -- Métadonnées
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Contraintes de clés étrangères
    FOREIGN KEY (id_temps) REFERENCES Dim_Temps(id_temps),
    FOREIGN KEY (id_client) REFERENCES Dim_Client(id_client),
    FOREIGN KEY (id_batiment) REFERENCES Dim_Batiment(id_batiment),
    FOREIGN KEY (id_region) REFERENCES Dim_Region(id_region),
    FOREIGN KEY (id_type_energie) REFERENCES Dim_Type_Energie(id_type_energie),
    FOREIGN KEY (id_compteur) REFERENCES Dim_Compteur(id_compteur),
    FOREIGN KEY (id_meteo) REFERENCES Dim_Meteo(id_meteo),

    -- Index pour optimiser les requêtes
    INDEX idx_temps (id_temps),
    INDEX idx_client (id_client),
    INDEX idx_batiment (id_batiment),
    INDEX idx_region (id_region),
    INDEX idx_type_energie (id_type_energie),
    INDEX idx_date_ajout (date_ajout)
) ENGINE=InnoDB;

-- ============================================================
-- VUES POUR L'ANALYSE
-- ============================================================

-- Vue: Consommation totale par client et période
CREATE OR REPLACE VIEW V_Consommation_Par_Client AS
SELECT
    dc.code_client,
    dc.nom_client,
    dt.annee,
    dt.mois,
    dte.nom_type_energie,
    SUM(fc.consommation_quantite) AS consommation_totale,
    SUM(fc.cout_energie) AS cout_total,
    AVG(fc.consommation_quantite) AS consommation_moyenne
FROM Fait_Consommation fc
JOIN Dim_Client dc ON fc.id_client = dc.id_client
JOIN Dim_Temps dt ON fc.id_temps = dt.id_temps
JOIN Dim_Type_Energie dte ON fc.id_type_energie = dte.id_type_energie
GROUP BY dc.code_client, dc.nom_client, dt.annee, dt.mois, dte.nom_type_energie;

-- Vue: Consommation par bâtiment
CREATE OR REPLACE VIEW V_Consommation_Par_Batiment AS
SELECT
    db.code_batiment,
    db.nom_batiment,
    db.type_batiment,
    dt.annee,
    dt.mois,
    dte.nom_type_energie,
    SUM(fc.consommation_quantite) AS consommation_totale,
    AVG(fc.consommation_par_m2) AS consommation_moyenne_m2
FROM Fait_Consommation fc
JOIN Dim_Batiment db ON fc.id_batiment = db.id_batiment
JOIN Dim_Temps dt ON fc.id_temps = dt.id_temps
JOIN Dim_Type_Energie dte ON fc.id_type_energie = dte.id_type_energie
GROUP BY db.code_batiment, db.nom_batiment, db.type_batiment, dt.annee, dt.mois, dte.nom_type_energie;

-- Vue: Corrélation Consommation vs Température
CREATE OR REPLACE VIEW V_Consommation_Temperature AS
SELECT
    dt.date_complete,
    dr.nom_region,
    dte.nom_type_energie,
    dm.temperature_moyenne,
    SUM(fc.consommation_quantite) AS consommation_totale
FROM Fait_Consommation fc
JOIN Dim_Temps dt ON fc.id_temps = dt.id_temps
JOIN Dim_Region dr ON fc.id_region = dr.id_region
JOIN Dim_Type_Energie dte ON fc.id_type_energie = dte.id_type_energie
LEFT JOIN Dim_Meteo dm ON fc.id_meteo = dm.id_meteo
WHERE dm.temperature_moyenne IS NOT NULL
GROUP BY dt.date_complete, dr.nom_region, dte.nom_type_energie, dm.temperature_moyenne;
