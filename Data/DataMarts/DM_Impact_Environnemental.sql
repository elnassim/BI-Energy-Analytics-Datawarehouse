-- ============================================================
-- Data Mart 3: Impact Environnemental
-- Architecture en Étoile (Star Schema)
-- ============================================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS DM_Impact_Environnemental;
USE DM_Impact_Environnemental;

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
    saison VARCHAR(20), -- Printemps, Été, Automne, Hiver
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (date_complete)
) ENGINE=InnoDB;

-- Dimension Bâtiment
CREATE TABLE IF NOT EXISTS Dim_Batiment (
    id_batiment INT PRIMARY KEY AUTO_INCREMENT,
    code_batiment VARCHAR(50) UNIQUE NOT NULL,
    nom_batiment VARCHAR(100) NOT NULL,
    type_batiment VARCHAR(50), -- Bureau, Résidentiel, Commercial, Industriel
    surface_m2 DECIMAL(10,2),
    nombre_occupants INT,
    certification_environnementale VARCHAR(50), -- LEED, HQE, BREEAM, Aucune
    niveau_certification VARCHAR(20), -- Bronze, Silver, Gold, Platinum
    annee_construction INT,
    a_systeme_recyclage BOOLEAN,
    a_panneaux_solaires BOOLEAN,
    adresse VARCHAR(255),
    ville VARCHAR(100),
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Région (Site)
CREATE TABLE IF NOT EXISTS Dim_Region (
    id_region INT PRIMARY KEY AUTO_INCREMENT,
    code_region VARCHAR(50) UNIQUE NOT NULL,
    nom_region VARCHAR(100) NOT NULL,
    pays VARCHAR(100),
    zone_climatique VARCHAR(50), -- Tropical, Tempéré, Continental, Polaire
    objectif_reduction_co2 DECIMAL(5,2), -- Pourcentage objectif de réduction
    objectif_recyclage DECIMAL(5,2), -- Pourcentage objectif de recyclage
    normes_environnementales VARCHAR(100),
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Type Énergie
CREATE TABLE IF NOT EXISTS Dim_Type_Energie (
    id_type_energie INT PRIMARY KEY AUTO_INCREMENT,
    code_type_energie VARCHAR(50) UNIQUE NOT NULL,
    nom_type_energie VARCHAR(50) NOT NULL, -- Électricité, Eau, Gaz
    est_renouvelable BOOLEAN, -- Si l'énergie est renouvelable
    facteur_emission_co2 DECIMAL(10,6), -- kg CO2 par unité (kWh ou m3)
    unite_mesure VARCHAR(20) NOT NULL, -- kWh, m3
    source_energie VARCHAR(100), -- Charbon, Nucléaire, Solaire, Éolien, Hydraulique
    impact_environnemental VARCHAR(20), -- Faible, Moyen, Élevé
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Indicateur Environnemental
CREATE TABLE IF NOT EXISTS Dim_Indicateur_Environnemental (
    id_indicateur INT PRIMARY KEY AUTO_INCREMENT,
    code_indicateur VARCHAR(50) UNIQUE NOT NULL,
    nom_indicateur VARCHAR(100) NOT NULL,
    categorie VARCHAR(50), -- Émissions, Recyclage, Eau, Déchets
    unite_mesure VARCHAR(20),
    seuil_alerte DECIMAL(15,4), -- Valeur seuil d'alerte
    seuil_critique DECIMAL(15,4), -- Valeur seuil critique
    description TEXT,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Dimension Type Déchet
CREATE TABLE IF NOT EXISTS Dim_Type_Dechet (
    id_type_dechet INT PRIMARY KEY AUTO_INCREMENT,
    code_type_dechet VARCHAR(50) UNIQUE NOT NULL,
    nom_type_dechet VARCHAR(100) NOT NULL, -- Plastique, Papier, Verre, Métal, Organique
    est_recyclable BOOLEAN,
    taux_recyclage_moyen DECIMAL(5,4), -- Taux moyen de recyclage pour ce type
    methode_traitement VARCHAR(100), -- Recyclage, Compostage, Incinération, Enfouissement
    impact_environnemental VARCHAR(20), -- Faible, Moyen, Élevé
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- TABLE DE FAITS
-- ============================================================

CREATE TABLE IF NOT EXISTS Fait_Impact_Environnemental (
    id_fait_environnemental BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Clés étrangères vers les dimensions
    id_temps INT NOT NULL,
    id_batiment INT NOT NULL,
    id_region INT NOT NULL,
    id_type_energie INT,
    id_indicateur INT,
    id_type_dechet INT,

    -- Mesures Environnementales (Faits)

    -- Émissions CO2
    emission_co2_kg DECIMAL(15,4), -- Émissions en kg de CO2
    emission_co2_par_m2 DECIMAL(10,4), -- Émissions par surface
    emission_co2_par_occupant DECIMAL(10,4), -- Émissions par personne

    -- Consommation Énergétique
    consommation_energie_kwh DECIMAL(15,4), -- Consommation en kWh équivalent
    consommation_eau_m3 DECIMAL(15,4), -- Consommation d'eau en m3

    -- Gestion des Déchets
    quantite_dechets_kg DECIMAL(15,4), -- Quantité totale de déchets en kg
    quantite_dechets_recycles_kg DECIMAL(15,4), -- Quantité recyclée en kg
    quantite_dechets_non_recycles_kg DECIMAL(15,4), -- Quantité non recyclée en kg
    taux_recyclage DECIMAL(5,4), -- Pourcentage de recyclage (0-1)

    -- KPI Calculés
    ratio_co2_consommation DECIMAL(10,6), -- kg CO2 / kWh
    score_environnemental INT, -- Score global (0-100)
    conformite_objectifs BOOLEAN, -- Si les objectifs sont atteints

    -- Indicateurs de Performance Environnementale
    reduction_co2_vs_annee_precedente DECIMAL(10,2), -- % de réduction
    amelioration_recyclage_vs_mois_precedent DECIMAL(10,2), -- % amélioration

    -- Économies réalisées
    economie_co2_kg DECIMAL(15,4), -- Réduction CO2 vs baseline
    economie_energie_kwh DECIMAL(15,4), -- Réduction énergie vs baseline

    -- Métadonnées
    date_mesure DATE, -- Date de la mesure environnementale
    source_donnees VARCHAR(100), -- Source du rapport
    validite_donnees BOOLEAN DEFAULT TRUE, -- Si les données sont valides

    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Contraintes de clés étrangères
    FOREIGN KEY (id_temps) REFERENCES Dim_Temps(id_temps),
    FOREIGN KEY (id_batiment) REFERENCES Dim_Batiment(id_batiment),
    FOREIGN KEY (id_region) REFERENCES Dim_Region(id_region),
    FOREIGN KEY (id_type_energie) REFERENCES Dim_Type_Energie(id_type_energie),
    FOREIGN KEY (id_indicateur) REFERENCES Dim_Indicateur_Environnemental(id_indicateur),
    FOREIGN KEY (id_type_dechet) REFERENCES Dim_Type_Dechet(id_type_dechet),

    -- Index pour optimiser les requêtes
    INDEX idx_temps (id_temps),
    INDEX idx_batiment (id_batiment),
    INDEX idx_region (id_region),
    INDEX idx_type_energie (id_type_energie),
    INDEX idx_date_ajout (date_ajout)
) ENGINE=InnoDB;

-- ============================================================
-- VUES POUR L'ANALYSE
-- ============================================================

-- Vue: Émissions totales de CO2 par bâtiment
CREATE OR REPLACE VIEW V_Emissions_Par_Batiment AS
SELECT
    db.code_batiment,
    db.nom_batiment,
    db.type_batiment,
    db.certification_environnementale,
    dt.annee,
    dt.mois,
    SUM(fe.emission_co2_kg) AS emission_co2_totale,
    AVG(fe.emission_co2_par_m2) AS emission_moyenne_par_m2,
    AVG(fe.emission_co2_par_occupant) AS emission_moyenne_par_occupant,
    AVG(fe.score_environnemental) AS score_moyen
FROM Fait_Impact_Environnemental fe
JOIN Dim_Batiment db ON fe.id_batiment = db.id_batiment
JOIN Dim_Temps dt ON fe.id_temps = dt.id_temps
GROUP BY db.code_batiment, db.nom_batiment, db.type_batiment,
         db.certification_environnementale, dt.annee, dt.mois;

-- Vue: Émissions par région et période
CREATE OR REPLACE VIEW V_Emissions_Par_Region AS
SELECT
    dr.code_region,
    dr.nom_region,
    dr.zone_climatique,
    dt.annee,
    dt.trimestre,
    SUM(fe.emission_co2_kg) AS emission_co2_totale,
    COUNT(DISTINCT fe.id_batiment) AS nombre_batiments,
    AVG(fe.taux_recyclage) AS taux_recyclage_moyen,
    AVG(fe.score_environnemental) AS score_environnemental_moyen
FROM Fait_Impact_Environnemental fe
JOIN Dim_Region dr ON fe.id_region = dr.id_region
JOIN Dim_Temps dt ON fe.id_temps = dt.id_temps
GROUP BY dr.code_region, dr.nom_region, dr.zone_climatique, dt.annee, dt.trimestre;

-- Vue: Évolution des émissions dans le temps
CREATE OR REPLACE VIEW V_Evolution_Emissions AS
SELECT
    dt.date_complete,
    dt.annee,
    dt.mois,
    SUM(fe.emission_co2_kg) AS emission_totale,
    AVG(fe.reduction_co2_vs_annee_precedente) AS reduction_moyenne,
    COUNT(DISTINCT fe.id_batiment) AS nombre_batiments_mesures
FROM Fait_Impact_Environnemental fe
JOIN Dim_Temps dt ON fe.id_temps = dt.id_temps
GROUP BY dt.date_complete, dt.annee, dt.mois
ORDER BY dt.date_complete;

-- Vue: Analyse du recyclage
CREATE OR REPLACE VIEW V_Analyse_Recyclage AS
SELECT
    db.code_batiment,
    db.nom_batiment,
    dt.annee,
    dt.mois,
    SUM(fe.quantite_dechets_kg) AS dechets_totaux,
    SUM(fe.quantite_dechets_recycles_kg) AS dechets_recycles,
    SUM(fe.quantite_dechets_non_recycles_kg) AS dechets_non_recycles,
    AVG(fe.taux_recyclage) AS taux_recyclage_moyen,
    AVG(fe.amelioration_recyclage_vs_mois_precedent) AS amelioration_moyenne
FROM Fait_Impact_Environnemental fe
JOIN Dim_Batiment db ON fe.id_batiment = db.id_batiment
JOIN Dim_Temps dt ON fe.id_temps = dt.id_temps
WHERE fe.quantite_dechets_kg IS NOT NULL
GROUP BY db.code_batiment, db.nom_batiment, dt.annee, dt.mois;

-- Vue: Classement des bâtiments les plus polluants
CREATE OR REPLACE VIEW V_Top_Batiments_Polluants AS
SELECT
    db.code_batiment,
    db.nom_batiment,
    db.type_batiment,
    dr.nom_region,
    SUM(fe.emission_co2_kg) AS emission_totale,
    AVG(fe.emission_co2_par_m2) AS emission_par_m2,
    AVG(fe.taux_recyclage) AS taux_recyclage_moyen,
    AVG(fe.score_environnemental) AS score_environnemental
FROM Fait_Impact_Environnemental fe
JOIN Dim_Batiment db ON fe.id_batiment = db.id_batiment
JOIN Dim_Region dr ON fe.id_region = dr.id_region
GROUP BY db.code_batiment, db.nom_batiment, db.type_batiment, dr.nom_region
ORDER BY emission_totale DESC;

-- Vue: Ratio CO2 / Consommation énergétique
CREATE OR REPLACE VIEW V_Ratio_CO2_Consommation AS
SELECT
    dt.annee,
    dt.mois,
    dte.nom_type_energie,
    SUM(fe.emission_co2_kg) AS emission_totale,
    SUM(fe.consommation_energie_kwh) AS consommation_totale,
    AVG(fe.ratio_co2_consommation) AS ratio_moyen_co2_kwh
FROM Fait_Impact_Environnemental fe
JOIN Dim_Temps dt ON fe.id_temps = dt.id_temps
LEFT JOIN Dim_Type_Energie dte ON fe.id_type_energie = dte.id_type_energie
WHERE fe.consommation_energie_kwh IS NOT NULL
GROUP BY dt.annee, dt.mois, dte.nom_type_energie;

-- Vue: Performance environnementale par type de bâtiment
CREATE OR REPLACE VIEW V_Performance_Type_Batiment AS
SELECT
    db.type_batiment,
    db.certification_environnementale,
    COUNT(DISTINCT db.id_batiment) AS nombre_batiments,
    AVG(fe.emission_co2_par_m2) AS emission_moyenne_par_m2,
    AVG(fe.taux_recyclage) AS taux_recyclage_moyen,
    AVG(fe.score_environnemental) AS score_moyen
FROM Fait_Impact_Environnemental fe
JOIN Dim_Batiment db ON fe.id_batiment = db.id_batiment
GROUP BY db.type_batiment, db.certification_environnementale;
