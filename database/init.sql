-- NextGIS Web Database Initialization Script
-- This script runs when the PostgreSQL container is first created

-- Create extensions if they don't exist (PostGIS should already be enabled by the image)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Set ownership of PostGIS tables to the application user
-- Replace 'nextgisweb' with your actual database user if different
ALTER TABLE spatial_ref_sys OWNER TO nextgisweb;
ALTER TABLE geography_columns OWNER TO nextgisweb;
ALTER TABLE geometry_columns OWNER TO nextgisweb;

-- Optional: Add custom SRIDs if needed
-- Example: INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) VALUES (...);

-- Grant necessary privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nextgisweb;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO nextgisweb;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'NextGIS Web database initialization completed successfully';
END $$;
