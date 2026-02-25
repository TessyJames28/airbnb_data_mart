-- ============================================================
-- WISHLIST & RATING STRUCTURE TEST SCRIPT
-- Validates integrity for:
-- Wishlist -> WishlistItem -> Rating -> Rating relations -> Rating summaries
-- ============================================================



-- ============================================================
-- WISHLIST CATEGORY TESTS
-- ============================================================

-- Test 1: Ensure wishlist categories exist
SELECT COUNT(*) AS total_categories
FROM WishlistCategory;

-- Test 2: Ensure no duplicate names
SELECT name, COUNT(*)
FROM WishlistCategory
GROUP BY name
HAVING COUNT(*) > 1;



-- ============================================================
-- WISHLIST TESTS
-- ============================================================

-- Test 1: Ensure wishlists exist
SELECT COUNT(*) AS total_wishlists
FROM Wishlist;

-- Test 2: Every wishlist must belong to a valid user
SELECT w.wishlist_id
FROM Wishlist w
LEFT JOIN Users u ON u.user_id = w.user_id
WHERE u.user_id IS NULL;

-- Test 3: Ensure visibility flag is not NULL
SELECT *
FROM Wishlist
WHERE is_public IS NULL;



-- ============================================================
-- WISHLIST ITEM TESTS
-- ============================================================

-- Test 1: Ensure wishlist items exist
SELECT COUNT(*) AS total_wishlist_items
FROM WishlistItem;

-- Test 2: Every wishlist item must reference valid wishlist and listing
SELECT wi.*
FROM WishlistItem wi
LEFT JOIN Wishlist w ON w.wishlist_id = wi.wishlist_id
LEFT JOIN Listing l ON l.listing_id = wi.listing_id
WHERE w.wishlist_id IS NULL
   OR l.listing_id IS NULL;

-- Test 3: Prevent duplicate listing in same wishlist
SELECT wishlist_id, listing_id, COUNT(*)
FROM WishlistItem
GROUP BY wishlist_id, listing_id
HAVING COUNT(*) > 1;



-- ============================================================
-- RATING TESTS
-- ============================================================

-- Test 1: Ensure ratings exist
SELECT COUNT(*) AS total_ratings
FROM Rating;

-- Test 2: Ensure rating value within range (0–5)
SELECT *
FROM Rating
WHERE rating_value < 0 OR rating_value > 5;

-- Test 3: Every rating must reference valid reservation and reviewer
SELECT r.*
FROM Rating r
LEFT JOIN Reservation res ON res.reservation_id = r.reservation_id
LEFT JOIN Profile p ON p.profile_id = r.reviewer_profile_id
WHERE res.reservation_id IS NULL
   OR p.profile_id IS NULL;



-- ============================================================
-- RATING LISTING TESTS
-- ============================================================

-- Test 1: Ensure FK integrity
SELECT rl.*
FROM RatingListing rl
LEFT JOIN Rating r ON r.rating_id = rl.rating_id
LEFT JOIN Listing l ON l.listing_id = rl.listing_id
WHERE r.rating_id IS NULL
   OR l.listing_id IS NULL;

-- Test 2: Duplicate prevention
SELECT rating_id, listing_id, COUNT(*)
FROM RatingListing
GROUP BY rating_id, listing_id
HAVING COUNT(*) > 1;



-- ============================================================
-- RATING GUEST TESTS
-- ============================================================

-- Test 1: FK integrity
SELECT rg.*
FROM RatingGuest rg
LEFT JOIN Rating r ON r.rating_id = rg.rating_id
LEFT JOIN Profile p ON p.profile_id = rg.guest_profile_id
WHERE r.rating_id IS NULL
   OR p.profile_id IS NULL;

-- Test 2: Duplicate prevention
SELECT rating_id, guest_profile_id, COUNT(*)
FROM RatingGuest
GROUP BY rating_id, guest_profile_id
HAVING COUNT(*) > 1;



-- ============================================================
-- RATING HOST TESTS
-- ============================================================

-- Test 1: FK integrity
SELECT rh.*
FROM RatingHost rh
LEFT JOIN Rating r ON r.rating_id = rh.rating_id
LEFT JOIN Profile p ON p.profile_id = rh.host_profile_id
WHERE r.rating_id IS NULL
   OR p.profile_id IS NULL;

-- Test 2: Duplicate prevention
SELECT rating_id, host_profile_id, COUNT(*)
FROM RatingHost
GROUP BY rating_id, host_profile_id
HAVING COUNT(*) > 1;



-- ============================================================
-- PROFILE RATING SUMMARY TESTS
-- ============================================================

-- Test 1: Ensure summaries reference valid profile
SELECT prs.*
FROM ProfileRatingSummary prs
LEFT JOIN Profile p ON p.profile_id = prs.profile_id
WHERE p.profile_id IS NULL;

-- Test 2: Validate average rating calculation
SELECT *
FROM ProfileRatingSummary
WHERE rating_count > 0
AND ROUND((rating_sum::decimal / rating_count), 2) <> avg_rating;



-- ============================================================
-- LISTING RATING SUMMARY TESTS
-- ============================================================

-- Test 1: Ensure summaries reference valid listing
SELECT lrs.*
FROM ListingRatingSummary lrs
LEFT JOIN Listing l ON l.listing_id = lrs.listing_id
WHERE l.listing_id IS NULL;

-- Test 2: Validate average rating calculation
SELECT *
FROM ListingRatingSummary
WHERE rating_count > 0
AND ROUND((rating_sum::decimal / rating_count), 2) <> avg_rating;



-- ============================================================
-- BUSINESS RULE TESTS
-- ============================================================

-- Test 1: Ensure only guests who made reservations can rate
SELECT r.rating_id
FROM Rating r
LEFT JOIN Reservation res ON res.reservation_id = r.reservation_id
WHERE res.reservation_id IS NULL;

-- Test 2: Prevent multiple ratings for same reservation by same reviewer
SELECT reservation_id, reviewer_profile_id, COUNT(*)
FROM Rating
GROUP BY reservation_id, reviewer_profile_id
HAVING COUNT(*) > 1;
