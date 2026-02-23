-- ============================================================
-- LOCATION STRUCTURE
-- This section models geographical hierarchy:
-- Continent -> Country -> City -> Address
-- ============================================================

-- ======================
-- Enable UUID generation
-- ======================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================================
-- Stores world continents
-- ============================================================
CREATE TABLE Continent (
  continent_id uuid PRIMARY KEY,
  name varchar(50) UNIQUE NOT NULL
);

-- ============================================================
-- Stores countries and links them to a continent
-- ============================================================
CREATE TABLE Country (
  country_id uuid PRIMARY KEY,
  name varchar(100) UNIQUE NOT NULL,
  iso_code varchar(3) NOT NULL,
  continent_id uuid REFERENCES Continent(continent_id)
);

-- ============================================================
-- Stores cities and links them to a country
-- ============================================================
CREATE TABLE City (
  city_id uuid PRIMARY KEY,
  name varchar(100) NOT NULL,
  country_id uuid REFERENCES Country(country_id)
);

-- ============================================================
-- Stores full address details.
-- Address can be reused by Profiles and Listings.
-- ============================================================
CREATE TABLE Address (
  address_id uuid PRIMARY KEY,
  address_line_1 varchar(250) NOT NULL,
  address_line_2 varchar(250),
  city_id uuid REFERENCES City(city_id),
  state_province varchar(100) NOT NULL,
  postal_code varchar(20) NOT NULL,
  country_id uuid REFERENCES Country(country_id),
  building_name varchar(100),
  floor_number varchar(10),
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

-- ============================================================
-- ADDRESS ROLE
-- Defines the purpose of an address
-- Example: Home, Billing, Business, Listing Location
-- ============================================================
CREATE TABLE AddressRole (
  address_role_id uuid PRIMARY KEY,
  name varchar(50) UNIQUE NOT NULL
);

-- ============================================================
-- PROFILE ADDRESS RELATION
-- Many-to-many relationship between Profile and Address.
-- Allows a profile to have multiple addresses with roles.
-- ============================================================
CREATE TABLE ProfileAddress (
  address_id uuid REFERENCES Address(address_id),
  profile_id uuid REFERENCES Profile(profile_id),
  address_role_id uuid REFERENCES AddressRole(address_role_id),
  is_active boolean NOT NULL,
  valid_from date NOT NULL,
  valid_to date,
  PRIMARY KEY (address_id, profile_id, address_role_id)
);
