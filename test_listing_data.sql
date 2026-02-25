-- ============================================================
-- LISTING STRUCTURE TEST SCRIPT
-- Validates integrity for:
-- PropertyType -> Amenities -> Listings -> Rooms -> Beds -> ListingAddress
-- ============================================================



-- ============================================================
-- PROPERTY TYPE TESTS
-- ============================================================

-- Test 1: Ensure property types exist
SELECT COUNT(*) AS total_property_types
FROM PropertyType;

-- Test 2: Ensure no duplicate names
SELECT name, COUNT(*)
FROM PropertyType
GROUP BY name
HAVING COUNT(*) > 1;



-- ============================================================
-- AMENITY CATEGORY TESTS
-- ============================================================

-- Test 1: Ensure amenity categories exist
SELECT COUNT(*) AS total_categories
FROM AmenityCategory;

-- Test 2: Ensure uniqueness
SELECT name, COUNT(*)
FROM AmenityCategory
GROUP BY name
HAVING COUNT(*) > 1;



-- ============================================================
-- AMENITY TESTS
-- ============================================================

-- Test 1: Ensure amenities exist
SELECT COUNT(*) AS total_amenities
FROM Amenity;

-- Test 2: Ensure each amenity has valid category
SELECT a.*
FROM Amenity a
LEFT JOIN AmenityCategory c ON c.category_id = a.category_id
WHERE c.category_id IS NULL;



-- ============================================================
-- LIST LOCATION TESTS
-- ============================================================

-- Test 1: Ensure locations exist
SELECT COUNT(*) AS total_locations
FROM ListLocation;

-- Test 2: Check duplicate location names
SELECT name, COUNT(*)
FROM ListLocation
GROUP BY name
HAVING COUNT(*) > 1;



-- ============================================================
-- LISTING TESTS
-- ============================================================

-- Test 1: Ensure listings exist
SELECT COUNT(*) AS total_listings
FROM Listing;

-- Test 2: Each listing must have valid host
SELECT l.listing_id
FROM Listing l
LEFT JOIN Profile p ON p.profile_id = l.host_id
WHERE p.profile_id IS NULL;

-- Test 3: Ensure listing host has role = host
SELECT l.listing_id, u.email
FROM Listing l
JOIN Profile p ON p.profile_id = l.host_id
JOIN Users u ON u.user_id = p.user_id
JOIN UserRole ur ON ur.user_id = u.user_id
JOIN Role r ON r.role_id = ur.role_id
WHERE r.role_type <> 'host';

-- Test 4: Check required fields
SELECT *
FROM Listing
WHERE title IS NULL
   OR description IS NULL
   OR room_count <= 0
   OR guest_capacity <= 0
   OR price_per_night <= 0;



-- ============================================================
-- LISTING AMENITY TESTS
-- ============================================================

-- Test 1: Ensure listings have amenities
SELECT listing_id
FROM Listing
LEFT JOIN ListingAmenity la USING(listing_id)
WHERE la.amenity_id IS NULL;

-- Test 2: Check FK integrity
SELECT la.*
FROM ListingAmenity la
LEFT JOIN Listing l ON l.listing_id = la.listing_id
LEFT JOIN Amenity a ON a.amenity_id = la.amenity_id
WHERE l.listing_id IS NULL OR a.amenity_id IS NULL;

-- Test 3: Duplicate check
SELECT listing_id, amenity_id, COUNT(*)
FROM ListingAmenity
GROUP BY listing_id, amenity_id
HAVING COUNT(*) > 1;



-- ============================================================
-- ROOM TYPE TESTS
-- ============================================================

-- Test 1: Ensure room types exist
SELECT COUNT(*) AS total_room_types
FROM RoomType;

-- Test 2: Ensure types like Entire Home, Private Room exist
SELECT *
FROM RoomType
WHERE name IN ('Entire Home', 'Private Room', 'Shared Room');



-- ============================================================
-- ROOM TESTS
-- ============================================================

-- Test 1: Ensure rooms exist
SELECT COUNT(*) AS total_rooms
FROM Room;

-- Test 2: Rooms must belong to valid listing
SELECT r.room_id
FROM Room r
LEFT JOIN Listing l ON l.listing_id = r.listing_id
WHERE l.listing_id IS NULL;

-- Test 3: Check valid room type
SELECT r.*
FROM Room r
LEFT JOIN RoomType rt ON rt.room_type_id = r.room_type_id
WHERE rt.room_type_id IS NULL;



-- ============================================================
-- BED TYPE TESTS
-- ============================================================

-- Test 1: Ensure bed types exist
SELECT COUNT(*) AS total_bed_types
FROM BedType;

-- Test 2: Duplicate check
SELECT name, COUNT(*)
FROM BedType
GROUP BY name
HAVING COUNT(*) > 1;



-- ============================================================
-- BED TESTS
-- ============================================================

-- Test 1: Beds must belong to valid room
SELECT b.*
FROM Bed b
LEFT JOIN Room r ON r.room_id = b.room_id
WHERE r.room_id IS NULL;

-- Test 2: Check bed type validity
SELECT b.*
FROM Bed b
LEFT JOIN BedType bt ON bt.bed_type_id = b.bed_type_id
WHERE bt.bed_type_id IS NULL;

-- Test 3: Quantity must be positive
SELECT *
FROM Bed
WHERE quantity <= 0;



-- ============================================================
-- ROOM AMENITY TESTS
-- ============================================================

-- Test 1: FK integrity
SELECT ra.*
FROM RoomAmenity ra
LEFT JOIN Room r ON r.room_id = ra.room_id
LEFT JOIN Amenity a ON a.amenity_id = ra.amenity_id
WHERE r.room_id IS NULL OR a.amenity_id IS NULL;

-- Test 2: Duplicate check
SELECT room_id, amenity_id, COUNT(*)
FROM RoomAmenity
GROUP BY room_id, amenity_id
HAVING COUNT(*) > 1;



-- ============================================================
-- LISTING ADDRESS TESTS
-- ============================================================

-- Test 1: Every listing must have an address
SELECT listing_id
FROM Listing
LEFT JOIN ListingAddress la USING(listing_id)
WHERE la.address_id IS NULL;

-- Test 2: FK integrity
SELECT la.*
FROM ListingAddress la
LEFT JOIN Listing l ON l.listing_id = la.listing_id
LEFT JOIN Address a ON a.address_id = la.address_id
LEFT JOIN AddressRole ar ON ar.address_role_id = la.address_role_id
WHERE l.listing_id IS NULL
   OR a.address_id IS NULL
   OR ar.address_role_id IS NULL;

-- Test 3: Duplicate check
SELECT address_id, listing_id, address_role_id, COUNT(*)
FROM ListingAddress
GROUP BY address_id, listing_id, address_role_id
HAVING COUNT(*) > 1;



-- ============================================================
-- BUSINESS RULE TESTS
-- ============================================================

-- Test 1: Listing capacity must be >= total bed capacity
SELECT l.listing_id
FROM Listing l
JOIN Room r ON r.listing_id = l.listing_id
JOIN Bed b ON b.room_id = r.room_id
GROUP BY l.listing_id, l.guest_capacity
HAVING SUM(b.quantity) < l.guest_capacity;

-- Test 2: Max nights must be >= min nights
SELECT *
FROM Listing
WHERE max_nights IS NOT NULL
AND max_nights < min_nights;
