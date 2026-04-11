-- ============================================================
-- database.sql (master orchestrator)
-- This runs all the module files in the right order
-- ============================================================

\i user_data.sql
\i address_data.sql
\i listing_data.sql
\i reservation_data.sql
\i wishlist_ratings_data.sql
\i insert_user_data.sql
\i insert_address_data.sql
\i insert_listing_data.sql
\i insert_reservation_data.sql
\i insert_wishlist_ratings_data.sql
-- \i test_user_data.sql
-- \i test_address_data.sql
-- \i test_listing_data.sql
-- \i test_reservation_data.sql
-- \i test_wishlist_ratings_data.sql
