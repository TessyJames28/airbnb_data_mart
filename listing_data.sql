-- ============================================================
-- LISTING STRUCTURE
-- This section models listing and property data:
-- PropertyType -> Amenity -> ListLocation -> Listing etc
-- ============================================================

-- ======================
-- Enable UUID generation
-- ======================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROPERTY TYPES
-- Defines the type of property (e.g., Apartment, House, Villa)
-- ============================================================
CREATE TABLE PropertyType (
  property_type_id uuid PRIMARY KEY,
  name varchar(50) NOT NULL,
  created_at timestamp DEFAULT now()
);

-- ============================================================
-- AMENITY CATEGORIES
-- Categories for amenities (e.g., Kitchen, Bathroom, Entertainment)
-- ============================================================
CREATE TABLE AmenityCategory (
  category_id uuid PRIMARY KEY,
  name varchar(50) UNIQUE NOT NULL
);

-- ============================================================
-- AMENITIES
-- Individual amenities linked to categories
-- ============================================================
CREATE TABLE Amenity (
  amenity_id uuid PRIMARY KEY,
  name varchar(50) UNIQUE NOT NULL,
  category_id uuid REFERENCES AmenityCategory(category_id)
);

-- ============================================================
-- LIST LOCATIONS
-- Defines specific locations within the platform (e.g., Downtown, Beachfront)
-- ============================================================
CREATE TABLE ListLocation (
  list_location_id uuid PRIMARY KEY,
  name varchar(50) NOT NULL
);

-- ============================================================
-- LISTINGS
-- Main listing table representing a host’s property
-- ============================================================
CREATE TABLE Listing (
  listing_id uuid PRIMARY KEY,
  host_id uuid REFERENCES Profile(profile_id),
  title varchar(250) NOT NULL,
  description text NOT NULL,
  property_type_id uuid REFERENCES PropertyType(property_type_id),
  list_location_id uuid REFERENCES ListLocation(list_location_id),
  room_count int NOT NULL,
  bathroom_count int NOT NULL,
  guest_capacity int NOT NULL,
  price_per_night decimal(12,2) NOT NULL,
  cleaning_fee decimal(6,2),
  min_nights int NOT NULL,
  max_nights int,
  host_checkin_time time,
  host_checkout_time time,
  added_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

-- ============================================================
-- LISTING AMENITIES
-- Many-to-many relation between listings and amenities
-- ============================================================
CREATE TABLE ListingAmenity (
  listing_id uuid REFERENCES Listing(listing_id),
  amenity_id uuid REFERENCES Amenity(amenity_id),
  is_active boolean DEFAULT true,
  PRIMARY KEY (listing_id, amenity_id)
);

-- ============================================================
-- ROOM TYPES
-- Defines types of rooms within a listing (e.g., Bedroom, Living Room)
-- ============================================================
CREATE TABLE RoomType (
  room_type_id uuid PRIMARY KEY,
  name varchar(50) UNIQUE NOT NULL,
  description varchar(500)
);

-- ============================================================
-- ROOMS
-- Rooms within a listing, linked to room types
-- ============================================================
CREATE TABLE Room (
  room_id uuid PRIMARY KEY,
  listing_id uuid REFERENCES Listing(listing_id),
  name varchar(50),
  room_type_id uuid REFERENCES RoomType(room_type_id),
  capacity int NOT NULL
);

-- ============================================================
-- BED TYPES
-- Types of beds (e.g., Queen, Single, Bunk)
-- ============================================================
CREATE TABLE BedType (
  bed_type_id uuid PRIMARY KEY,
  name varchar(50) UNIQUE NOT NULL
);

-- ============================================================
-- BEDS
-- Beds inside each room, linked to bed types
-- ============================================================
CREATE TABLE Bed (
  bed_id uuid PRIMARY KEY,
  room_id uuid REFERENCES Room(room_id),
  bed_type_id uuid REFERENCES BedType(bed_type_id),
  quantity int NOT NULL
);

-- ============================================================
-- ROOM AMENITIES
-- Many-to-many relation between rooms and amenities
-- ============================================================
CREATE TABLE RoomAmenity (
  room_id uuid REFERENCES Room(room_id),
  amenity_id uuid REFERENCES Amenity(amenity_id),
  PRIMARY KEY (room_id, amenity_id)
);

-- ============================================================
-- LISTING ADDRESS RELATION
-- Many-to-many relationship between Listing and Address.
-- Allows listings to have multiple addresses with roles.
-- ============================================================
CREATE TABLE ListingAddress (
  address_id uuid REFERENCES Address(address_id),
  listing_id uuid REFERENCES Listing(listing_id),
  address_role_id uuid REFERENCES AddressRole(address_role_id),
  is_active boolean NOT NULL,
  valid_from date NOT NULL,
  valid_to date,
  PRIMARY KEY (address_id, listing_id, address_role_id)
);
