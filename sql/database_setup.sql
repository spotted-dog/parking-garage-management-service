CREATE SCHEMA garage_manager AUTHORIZATION sdd_admin;  -- user owns the schema

GRANT CONNECT ON DATABASE the_tribal_dog TO sdd_admin;
GRANT USAGE ON SCHEMA garage_manager TO sdd_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA garage_manager TO sdd_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA garage_manager
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sdd_admin;
    