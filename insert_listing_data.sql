-- ============================================================
-- LISTING DATA INSERT SCRIPT
-- This file inserts sample data for the listing structure.
-- Only users with role = 'host' can create listings.
-- Each listing is linked to property type, room type,
-- amenities, rooms, beds and listing address.
-- ============================================================


-- ============================================================
-- PROPERTY TYPES
-- Defines types of properties available on the platform
-- ============================================================
INSERT INTO PropertyType (property_type_id, name)
VALUES
(uuid_generate_v4(), 'Apartment'),
(uuid_generate_v4(), 'House'),
(uuid_generate_v4(), 'Villa'),
(uuid_generate_v4(), 'Cottage'),
(uuid_generate_v4(), 'Studio'),
(uuid_generate_v4(), 'Townhouse'),
(uuid_generate_v4(), 'Loft'),
(uuid_generate_v4(), 'Bungalow'),
(uuid_generate_v4(), 'Guesthouse'),
(uuid_generate_v4(), 'Penthouse'),
(uuid_generate_v4(), 'Duplex'),
(uuid_generate_v4(), 'Farmhouse'),
(uuid_generate_v4(), 'Chalet'),
(uuid_generate_v4(), 'Cabin'),
(uuid_generate_v4(), 'Mansion'),
(uuid_generate_v4(), 'Terraced House'),
(uuid_generate_v4(), 'Maisonette'),
(uuid_generate_v4(), 'Ranch'),
(uuid_generate_v4(), 'Serviced Apartment'),
(uuid_generate_v4(), 'Condominium');



-- ============================================================
-- ROOM TYPES
-- Defines what guests are paying for
-- (Entire place, Private room, Shared room)
-- ============================================================
INSERT INTO RoomType (room_type_id, name, description)
VALUES
(uuid_generate_v4(), 'Entire Place', 'Guest has the entire property to themselves'),
(uuid_generate_v4(), 'Private Room', 'Guest has a private room but shares common areas'),
(uuid_generate_v4(), 'Shared Room', 'Guest shares sleeping area with others'),
(uuid_generate_v4(), 'Single Room', 'One person in a private room'),
(uuid_generate_v4(), 'Double Room', 'Two people in a private room'),
(uuid_generate_v4(), 'Twin Room', 'Two single beds in a private room'),
(uuid_generate_v4(), 'Triple Room', 'Three people in a private room'),
(uuid_generate_v4(), 'Quad Room', 'Four people in a private room'),
(uuid_generate_v4(), 'Dormitory', 'Multiple beds in one shared room'),
(uuid_generate_v4(), 'Studio Room', 'Private studio space for one or two guests'),
(uuid_generate_v4(), 'Family Room', 'Private room suitable for families'),
(uuid_generate_v4(), 'Shared Dorm Bed', 'Single bed in a shared dormitory room'),
(uuid_generate_v4(), 'Cabin Room', 'Individual room within a cabin shared by guests'),
(uuid_generate_v4(), 'Bunk Bed Room', 'Private room with bunk beds for multiple guests'),
(uuid_generate_v4(), 'Suite', 'Private room with additional living space'),
(uuid_generate_v4(), 'Accessible Room', 'Room designed for guests with disabilities'),
(uuid_generate_v4(), 'Luxury Room', 'High-end private room with premium amenities'),
(uuid_generate_v4(), 'Budget Room', 'Simple private room at an affordable rate'),
(uuid_generate_v4(), 'Shared Apartment Room', 'Private room in a shared apartment'),
(uuid_generate_v4(), 'Loft Room', 'Private room within a loft-style unit');



-- ============================================================
-- AMENITY CATEGORIES
-- Groups amenities into logical sections
-- ============================================================
INSERT INTO AmenityCategory (category_id, name)
VALUES
(uuid_generate_v4(), 'Kitchen'),
(uuid_generate_v4(), 'Bathroom'),
(uuid_generate_v4(), 'Bedroom'),
(uuid_generate_v4(), 'Entertainment'),
(uuid_generate_v4(), 'Safety'),
(uuid_generate_v4(), 'Outdoor'),
(uuid_generate_v4(), 'Internet'),
(uuid_generate_v4(), 'Parking'),
(uuid_generate_v4(), 'Heating'),
(uuid_generate_v4(), 'Cooling'),
(uuid_generate_v4(), 'Laundry'),
(uuid_generate_v4(), 'Accessibility'),
(uuid_generate_v4(), 'Fitness'),
(uuid_generate_v4(), 'Workspace'),
(uuid_generate_v4(), 'Pet-Friendly'),
(uuid_generate_v4(), 'Dining'),
(uuid_generate_v4(), 'View'),
(uuid_generate_v4(), 'Storage'),
(uuid_generate_v4(), 'Transport'),
(uuid_generate_v4(), 'Cleaning Services');



-- ============================================================
-- AMENITIES
-- Individual amenities linked to categories (20+ records)
-- ============================================================
INSERT INTO Amenity (amenity_id, name, category_id)
SELECT uuid_generate_v4(), amenity_name, ac.category_id
FROM (
VALUES
('WiFi','Internet'),
('Smart TV','Entertainment'),
('Netflix','Entertainment'),
('Air Conditioning','Bedroom'),
('Heater','Bedroom'),
('Refrigerator','Kitchen'),
('Microwave','Kitchen'),
('Dishwasher','Kitchen'),
('Washing Machine','Bathroom'),
('Dryer','Bathroom'),
('Hair Dryer','Bathroom'),
('Fire Extinguisher','Safety'),
('Smoke Detector','Safety'),
('First Aid Kit','Safety'),
('Balcony','Outdoor'),
('Garden','Outdoor'),
('BBQ Grill','Outdoor'),
('Free Parking','Parking'),
('Garage','Parking'),
('Workspace','Bedroom'),
('Iron','Bedroom'),
('Hot Water','Bathroom')
) AS a(amenity_name, category_name)
JOIN AmenityCategory ac ON ac.name = a.category_name;



-- ============================================================
-- LIST LOCATIONS
-- Defines where listing is situated logically in platform
-- ============================================================
INSERT INTO ListLocation (list_location_id, name)
VALUES
(uuid_generate_v4(), 'Downtown'),
(uuid_generate_v4(), 'City Center'),
(uuid_generate_v4(), 'Beachfront'),
(uuid_generate_v4(), 'Mountain View'),
(uuid_generate_v4(), 'Suburban'),
(uuid_generate_v4(), 'Island'),
(uuid_generate_v4(), 'Riverside'),
(uuid_generate_v4(), 'Business District'),
(uuid_generate_v4(), 'Airport Area'),
(uuid_generate_v4(), 'University Area'),
(uuid_generate_v4(), 'Historic District'),
(uuid_generate_v4(), 'Countryside'),
(uuid_generate_v4(), 'Lakefront'),
(uuid_generate_v4(), 'Resort Area'),
(uuid_generate_v4(), 'Old Town'),
(uuid_generate_v4(), 'Shopping District'),
(uuid_generate_v4(), 'Industrial Area'),
(uuid_generate_v4(), 'Harbor Area'),
(uuid_generate_v4(), 'Parkside'),
(uuid_generate_v4(), 'Cliffside');



-- ============================================================
-- LISTINGS
-- Only profiles with role = 'host' can create listings
-- At least 20 listings generated
-- ============================================================
\echo 'Inserting into Listing'
INSERT INTO Listing (
    listing_id,
    host_id,
    title,
    description,
    property_type_id,
    list_location_id,
    room_count,
    bathroom_count,
    guest_capacity,
    price_per_night,
    cleaning_fee,
    min_nights,
    max_nights,
    host_checkin_time,
    host_checkout_time
)
SELECT
uuid_generate_v4(),
p.profile_id,
'Comfort Stay ' || row_number() OVER (),
'A beautiful and comfortable space perfect for short and long stays.',
(SELECT property_type_id FROM PropertyType ORDER BY random() LIMIT 1),
(SELECT list_location_id FROM ListLocation ORDER BY random() LIMIT 1),
3,
2,
4,
80.00 + (random()*70)::int,
25.00,
1,
14,
'14:00',
'11:00'
FROM Profile p
JOIN UserRole ur ON ur.user_id = p.user_id
JOIN Role r ON r.role_id = ur.role_id
CROSS JOIN generate_series(1,10)
WHERE r.role_type = 'host';



-- ============================================================
-- LISTING AMENITIES
-- Assign amenities to listings (multiple per listing)
-- ============================================================
\echo 'Inserting into ListingAmenity'
INSERT INTO ListingAmenity (listing_id, amenity_id)
SELECT
l.listing_id,
a.amenity_id
FROM Listing l
CROSS JOIN LATERAL (
SELECT amenity_id
FROM Amenity
ORDER BY random()
LIMIT 10
) a;
-- l.listing_id, a.amenity_id
-- FROM Listing l
-- CROSS JOIN Amenity a;
-- LIMIT 100;



-- ============================================================
-- ROOMS
-- Each listing gets bedroom spaces
-- ============================================================
\echo 'Inserting into Room'
INSERT INTO Room (room_id, listing_id, name, room_type_id, capacity)
SELECT
    uuid_generate_v4(),
    l.listing_id,
    'Main Space ' || row_number() OVER (),
    rt.room_type_id,
    2
FROM Listing l
CROSS JOIN LATERAL (
SELECT room_type_id
FROM RoomType
ORDER BY random()
LIMIT 1
) rt;
--     uuid_generate_v4(),
--     l.listing_id,
--     'Main Space ' || row_number() OVER (),
--     rt.room_type_id,
--     2
-- FROM Listing l
-- JOIN RoomType rt ON rt.name = 'Entire Place'
-- LIMIT 20;



-- ============================================================
-- BED TYPES
-- Types of beds available
-- ============================================================
\echo 'Inserting into BedType'
INSERT INTO BedType (bed_type_id, name)
VALUES
(uuid_generate_v4(), 'Single'),
(uuid_generate_v4(), 'Double'),
(uuid_generate_v4(), 'Queen'),
(uuid_generate_v4(), 'King'),
(uuid_generate_v4(), 'Bunk Bed'),
(uuid_generate_v4(), 'Sofa Bed'),
(uuid_generate_v4(), 'Twin'),
(uuid_generate_v4(), 'Twin XL'),
(uuid_generate_v4(), 'California King'),
(uuid_generate_v4(), 'Futon'),
(uuid_generate_v4(), 'Murphy Bed'),
(uuid_generate_v4(), 'Daybed'),
(uuid_generate_v4(), 'Trundle Bed'),
(uuid_generate_v4(), 'Air Mattress'),
(uuid_generate_v4(), 'Crib'),
(uuid_generate_v4(), 'Toddler Bed'),
(uuid_generate_v4(), 'Rollaway Bed'),
(uuid_generate_v4(), 'Hammock'),
(uuid_generate_v4(), 'Water Bed'),
(uuid_generate_v4(), 'Tatami Bed');



-- ============================================================
-- BEDS
-- Assign beds to rooms
-- ============================================================
\echo 'Inserting into BedType'
INSERT INTO Bed (bed_id, room_id, bed_type_id, quantity)
SELECT
    uuid_generate_v4(),
    r.room_id,
    bt.bed_type_id,
    1
FROM Room r
CROSS JOIN LATERAL (
SELECT bed_type_id
FROM BedType
ORDER BY random()
LIMIT 1
) bt;
--     uuid_generate_v4(),
--     r.room_id,
--     bt.bed_type_id,
--     1
-- FROM Room r
-- JOIN BedType bt ON bt.name = 'Queen'
-- LIMIT 20;



-- ============================================================
-- ROOM AMENITY
-- Assign amenities to rooms (multiple per room)
-- ============================================================
\echo 'Inserting into RoomAmenity'
INSERT INTO RoomAmenity (room_id, amenity_id)
SELECT
r.room_id,
a.amenity_id
FROM Room r
CROSS JOIN LATERAL (
SELECT amenity_id
FROM Amenity
ORDER BY random()
LIMIT 5
) a;



-- ============================================================
-- LISTING ADDRESS RELATION
-- Each listing must have a Listing Location address
-- ============================================================
\echo 'Inserting into ListingAddress'
INSERT INTO ListingAddress (
    address_id,
    listing_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
a.address_id,
l.listing_id,
ar.address_role_id,
TRUE,
CURRENT_DATE
FROM Listing l
CROSS JOIN LATERAL (
SELECT address_id
FROM Address
ORDER BY random()
LIMIT 1
) a
JOIN AddressRole ar ON ar.name = 'Listing Location';
-- SELECT
--     a.address_id,
--     l.listing_id,
--     ar.address_role_id,
--     TRUE,
--     CURRENT_DATE
-- FROM Listing l
-- JOIN Address a ON TRUE
-- JOIN AddressRole ar ON ar.name = 'Listing Location'
-- LIMIT 20;
