# === HuaDian PostgreSQL 16 + pgvector + PostGIS + pg_trgm ===
#
# Strategy: pgvector/pgvector:pg16 as base (pgvector pre-built),
# then install PostGIS via apt.
# See ADR-007 §R-5 and T-P0-001 §4.1.
#
# Verification: docker exec huadian-postgres psql -U huadian -c '\dx'
# Must show: vector, postgis, postgis_topology, pg_trgm

FROM pgvector/pgvector:pg16

LABEL maintainer="HuaDian DevOps <devops@huadian.dev>"
LABEL description="PostgreSQL 16 with pgvector, PostGIS, and pg_trgm for HuaDian"

# Install PostGIS from official Debian/PG apt repo (already in pgvector base image sources)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       postgresql-16-postgis-3 \
       postgresql-16-postgis-3-scripts \
    && rm -rf /var/lib/apt/lists/*
