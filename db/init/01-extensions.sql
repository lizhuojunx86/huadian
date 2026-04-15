-- ============================================
-- HuaDian: Enable required PostgreSQL extensions
-- Runs automatically on first container start via docker-entrypoint-initdb.d
-- ============================================

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
