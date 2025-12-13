-- Script SQL pour créer la base de données Hunger-Talk
-- À exécuter dans PostgreSQL

-- Créer la base de données (si elle n'existe pas déjà)
CREATE DATABASE hungertalk_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'French_France.1252'
    LC_CTYPE = 'French_France.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Se connecter à la base de données (à faire manuellement)
-- \c hungertalk_db

-- Note: Les tables seront créées automatiquement par Alembic lors des migrations
-- Ce fichier sert uniquement à créer la base de données initiale

