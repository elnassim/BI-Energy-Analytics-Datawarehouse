CREATE DATABASE IF NOT EXISTS energy_analytics_dw_ops
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE energy_analytics_dw_ops;


DROP TABLE IF EXISTS paiements;
DROP TABLE IF EXISTS factures;
DROP TABLE IF EXISTS mesures_compteur;
DROP TABLE IF EXISTS compteurs;
DROP TABLE IF EXISTS contrats;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS batiments;
DROP TABLE IF EXISTS regions;

-- ---------- Parents
CREATE TABLE regions (
  id_region     VARCHAR(10)  NOT NULL,
  nom_region    VARCHAR(100) NOT NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_region)
) ENGINE=InnoDB;

CREATE TABLE batiments (
  id_batiment   VARCHAR(10)  NOT NULL,
  id_region     VARCHAR(10)  NOT NULL,
  nom_batiment  VARCHAR(120) NOT NULL,
  type_batiment VARCHAR(50)  NOT NULL,   -- bureau/usine/hopital/...
  surface_m2    INT          NOT NULL,
  annee_construction INT     NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_batiment),
  KEY idx_batiments_region (id_region),
  CONSTRAINT fk_batiments_regions
    FOREIGN KEY (id_region) REFERENCES regions(id_region)
) ENGINE=InnoDB;

CREATE TABLE clients (
  id_client     INT          NOT NULL,
  nom_client    VARCHAR(120) NOT NULL,
  email         VARCHAR(120) NULL,
  telephone     VARCHAR(30)  NULL,
  segment       VARCHAR(50)  NULL, -- PME/Entreprise/Administration...
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_client)
) ENGINE=InnoDB;

-- ---------- Contract: who is responsible for which building (finance link)
CREATE TABLE contrats (
  id_contrat    INT          NOT NULL,
  id_client     INT          NOT NULL,
  id_batiment   VARCHAR(10)  NOT NULL,
  date_debut    DATE         NOT NULL,
  date_fin      DATE         NULL,
  statut        VARCHAR(30)  NOT NULL, -- actif/resilie/suspendu
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_contrat),
  KEY idx_contrats_client (id_client),
  KEY idx_contrats_batiment (id_batiment),
  CONSTRAINT fk_contrats_clients
    FOREIGN KEY (id_client) REFERENCES clients(id_client),
  CONSTRAINT fk_contrats_batiments
    FOREIGN KEY (id_batiment) REFERENCES batiments(id_batiment)
) ENGINE=InnoDB;

-- ---------- Meters (used by JSON too)
CREATE TABLE compteurs (
  compteur_id   VARCHAR(20)  NOT NULL,   -- ELEC_001 / EAU_001 / GAZ_001...
  id_batiment   VARCHAR(10)  NOT NULL,
  type_energie  VARCHAR(20)  NOT NULL,   -- electricite/eau/gaz
  unite         VARCHAR(10)  NOT NULL,   -- KWh/m3
  installation_date DATE     NULL,
  statut        VARCHAR(20)  NOT NULL,   -- actif/hs
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (compteur_id),
  KEY idx_compteurs_batiment (id_batiment),
  CONSTRAINT fk_compteurs_batiments
    FOREIGN KEY (id_batiment) REFERENCES batiments(id_batiment)
) ENGINE=InnoDB;

-- ---------- Invoices (rentability / finance mart)
CREATE TABLE factures (
  id_facture    INT          NOT NULL,
  id_contrat    INT          NOT NULL,
  periode_debut DATE         NOT NULL,
  periode_fin   DATE         NOT NULL,
  montant_ttc   DECIMAL(10,2) NOT NULL,
  cout_energie  DECIMAL(10,2) NOT NULL,   -- cost side
  autres_couts  DECIMAL(10,2) NOT NULL DEFAULT 0,
  statut        VARCHAR(20)  NOT NULL,    -- payee/en_retard/annulee
  date_facture  DATE         NOT NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_facture),
  KEY idx_factures_contrat (id_contrat),
  KEY idx_factures_dates (date_facture),
  CONSTRAINT fk_factures_contrats
    FOREIGN KEY (id_contrat) REFERENCES contrats(id_contrat)
) ENGINE=InnoDB;

CREATE TABLE paiements (
  id_paiement   INT          NOT NULL,
  id_facture    INT          NOT NULL,
  date_paiement DATE         NOT NULL,
  montant_paye  DECIMAL(10,2) NOT NULL,
  mode_paiement VARCHAR(30)  NULL,        -- virement/carte/especes
  statut        VARCHAR(20)  NOT NULL,    -- paye/refuse/en_attente
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_paiement),
  KEY idx_paiements_facture (id_facture),
  CONSTRAINT fk_paiements_factures
    FOREIGN KEY (id_facture) REFERENCES factures(id_facture)
) ENGINE=InnoDB;


