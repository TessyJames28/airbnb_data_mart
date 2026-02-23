-- ============================================================
-- database.sql (master orchestrator)
-- This runs all the module files in the right order
-- ============================================================
\i user_data.sql
\i address_data.sql
\i listing_data.sql
\i reservation_data.sql
\i wishlist_ratings.sql
