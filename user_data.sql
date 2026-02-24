-- Create Database table for user data based on the ERD model created

-- ============================================================
-- LUSER STRUCTURE
-- This section models user data structure:
-- Users -> Profiles -> Roles -> Socials -> Languages
-- ============================================================

-- ======================
-- Enable UUID generation
-- ======================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUM for host language proficiency level
CREATE TYPE proficiency_level_enum AS ENUM (
    'native',
    'fluent',
    'beginner'
);

-- =============================================================
-- USERS: Create users table to store authentication information
-- =============================================================
CREATE TABLE Users (
  user_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  email varchar(255) UNIQUE NOT NULL,
  phone_number varchar(20) NOT NULL,
  password varchar(255) NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp DEFAULT now(),
  last_login timestamp,
  updated_at timestamp DEFAULT now()
);

-- ===============================================================
-- PROFILE: Create profiles table to store additional user details
-- One-to-one relationship with users
-- ===============================================================
CREATE TABLE Profile (
  profile_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid UNIQUE REFERENCES Users(user_id) ON DELETE CASCADE,
  image_url text,
  first_name varchar(100) NOT NULL,
  last_name varchar(100) NOT NULL
);

-- =======================================
-- ROLES: Defines roles each user can have
-- =======================================
CREATE TABLE Role (
  role_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  role_type varchar(50) UNIQUE NOT NULL
);

-- ========================================================
-- USER_ROLES: Defines a one-to-many role for a single user
-- ========================================================

CREATE TABLE UserRole (
  user_id uuid REFERENCES Users(user_id) ON DELETE CASCADE,
  role_id uuid REFERENCES Role(role_id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);

-- ====================================================================
-- SOCIALS: Stores the different social platforms users/host belongs to
-- ====================================================================
CREATE TABLE Social (
  social_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  social_platform varchar(50) UNIQUE NOT NULL
);

-- ============================================================================
-- PROFILE_SOCIALS: Stores a compilation of different social platforms for user
-- Defines a one-to-many relationship with socials table
-- ============================================================================

CREATE TABLE ProfileSocial (
  profile_id uuid REFERENCES Profile(profile_id) ON DELETE CASCADE,
  social_id uuid REFERENCES Social(social_id),
  social_handle varchar(100) NOT NULL,
  url text,
  is_primary boolean DEFAULT false,
  PRIMARY KEY (profile_id, social_id)
);

-- ========================================================
-- LANGUAGE: Defines the different languages host can speak
-- ========================================================
CREATE TABLE Language (
  language_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  language_name varchar(100) NOT NULL,
  iso_code varchar(10) UNIQUE
);

-- =============================================================
-- HOST_LANGUAGE: Stores the different languages the host speaks
-- Defines a one-to-many relationship with languages table
-- =============================================================
CREATE TABLE HostLanguage (
  profile_id uuid REFERENCES Profile(profile_id) ON DELETE CASCADE,
  language_id uuid REFERENCES Language(language_id),
  proficiency_level proficiency_level_enum NOT NULL,
  PRIMARY KEY (profile_id, language_id)
);
