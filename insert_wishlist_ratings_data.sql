-- ============================================================
-- WISHLIST AND RATING DATA INSERT SCRIPT
-- This file inserts realistic test data for:
-- 1. Wishlist categories
-- 2. Wishlists
-- 3. Wishlist items
-- 4. Ratings and reviews
-- 5. Rating summaries
--
-- RULES:
-- 1. Only users with role = 'guest' create wishlists
-- 2. Wishlist items must reference existing listings
-- 3. Ratings must come from reservations
-- 4. Listing summaries calculated from ratings
-- ============================================================



-- ============================================================
-- WISHLIST CATEGORIES
-- 20 categories
-- ============================================================
INSERT INTO WishlistCategory (name, description)
VALUES
('Favorites','Listings user likes'),
('Dream Trips','Future travel goals'),
('Beach Escapes','Beachfront homes'),
('City Stays','Downtown apartments'),
('Family Trips','Family friendly homes'),
('Luxury Villas','High-end villas'),
('Budget Travel','Affordable stays'),
('Weekend Getaway','Short stays'),
('Business Trips','Work-related travel'),
('Adventure Travel','Nature and adventure'),
('Romantic Trips','Couple travel'),
('Mountain Cabins','Cabins and lodges'),
('Staycation','Local relaxation'),
('Student Trips','Cheap student stays'),
('Group Trips','Large group houses'),
('Wedding Trips','Event stays'),
('Festival Trips','Concert/festival stays'),
('Spa Retreat','Wellness travel'),
('Safari Trips','Wildlife travel'),
('Cultural Trips','Historic locations');



-- ============================================================
-- WISHLISTS
-- Only users with role = guest
-- ============================================================
INSERT INTO Wishlist (
    user_id,
    wishlist_category_id,
    name,
    description,
    is_public
)
SELECT
    u.user_id,
    wc.wishlist_category_id,
    'Wishlist ' || row_number() OVER (),
    'My saved listings',
    TRUE
FROM Users u
JOIN UserRole ur ON ur.user_id = u.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN WishlistCategory wc ON TRUE
WHERE r.role_type = 'guest'
LIMIT 20;



-- ============================================================
-- WISHLIST ITEMS
-- Add listings into wishlists
-- ============================================================
INSERT INTO WishlistItem (
    wishlist_id,
    listing_id
)
SELECT
    w.wishlist_id,
    l.listing_id
FROM Wishlist w
JOIN listing l ON TRUE
LIMIT 40;



-- ============================================================
-- RATINGS
-- Only guests rate after reservation
-- ============================================================
INSERT INTO Rating (
    reservation_id,
    reviewer_profile_id,
    rating_value,
    comment
)
SELECT
    r.reservation_id,
    r.guest_id,
    3 + (random()*2)::int,
    'Great stay, very comfortable'
FROM reservation r;



-- ============================================================
-- RATING LISTING
-- Link rating to listing
-- ============================================================
INSERT INTO RatingListing (
    rating_id,
    listing_id
)
SELECT
    ra.rating_id,
    res.listing_id
FROM Rating ra
JOIN reservation res ON res.reservation_id = ra.reservation_id;



-- ============================================================
-- RATING HOST
-- Guest rates host
-- ============================================================
INSERT INTO RatingHost (
    rating_id,
    host_profile_id
)
SELECT
    ra.rating_id,
    l.host_id
FROM Rating ra
JOIN reservation res ON res.reservation_id = ra.reservation_id
JOIN listing l ON l.listing_id = res.listing_id;



-- ============================================================
-- RATING GUEST
-- Host rates guest
-- ============================================================
INSERT INTO RatingGuest (
    rating_id,
    guest_profile_id
)
SELECT
    ra.rating_id,
    res.guest_id
FROM Rating ra
JOIN reservation res ON res.reservation_id = ra.reservation_id;



-- ============================================================
-- PROFILE RATING SUMMARY
-- Aggregate ratings per profile
-- ============================================================
\echo 'Inserting into ProfileRatingSummary'
INSERT INTO ProfileRatingSummary (
    profile_id,
    rating_count,
    rating_sum,
    avg_rating
)
SELECT
    rh.host_profile_id AS profile_id,
    COUNT(*) AS rating_count,
    SUM(r.rating_value) AS rating_sum,
    AVG(r.rating_value) AS avg_rating
FROM Rating r
LEFT JOIN RatingHost rh ON rh.rating_id = r.rating_id
WHERE rh.host_profile_id IS NOT NULL
GROUP BY rh.host_profile_id

UNION ALL

SELECT
    gh.guest_profile_id AS profile_id,
    COUNT(*) AS rating_count,
    SUM(r.rating_value) AS rating_sum,
    AVG(r.rating_value) AS avg_rating
FROM Rating r
LEFT JOIN RatingGuest gh ON gh.rating_id = r.rating_id
WHERE gh.guest_profile_id IS NOT NULL
GROUP BY gh.guest_profile_id;



-- ============================================================
-- LISTING RATING SUMMARY
-- Aggregate ratings per listing
-- ============================================================
\echo 'Inserting into ListingRatingSummary'
INSERT INTO ListingRatingSummary (
    listing_id,
    rating_count,
    rating_sum,
    avg_rating
)
SELECT
    rl.listing_id,
    COUNT(*),
    SUM(r.rating_value),
    AVG(r.rating_value)
FROM Rating r
JOIN RatingListing rl ON rl.rating_id = r.rating_id
GROUP BY rl.listing_id;
