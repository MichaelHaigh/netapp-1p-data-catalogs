#!/bin/bash
set -euo pipefail

PGPASSWORD=${ps_ic_password} psql "user=icpostgresql host=${host} port=5432 dbname=postgres target_session_attrs=read-write" <<SQL
\set af_pass `echo ${ps_af_password}`
\set om_pass `echo ${ps_om_password}`
CREATE DATABASE airflow_db;
CREATE USER airflow WITH PASSWORD :'af_pass';
GRANT ALL PRIVILEGES ON DATABASE "airflow_db" to airflow;
CREATE DATABASE openmetadata_db;
CREATE USER openmetadata WITH PASSWORD :'om_pass';
GRANT ALL PRIVILEGES ON DATABASE "openmetadata_db" to openmetadata;
\connect airflow_db
GRANT ALL ON SCHEMA public TO airflow;
\connect openmetadata_db
GRANT ALL ON SCHEMA public TO openmetadata;
SQL
