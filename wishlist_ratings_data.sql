-- ============================================================
-- WISHLIST SYSTEM
-- Stores user wishlists, categories, and items
-- ============================================================

-- ======================
-- Enable UUID generation
-- ======================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- Wishlist categories (e.g., Favorites, Dream Trips)
-- ============================================================
CREATE TABLE WishlistCategory (
    wishlist_category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(250) NOT NULL,
    description VARCHAR(500) NOT NULL
);

-- ============================================================
-- User wishlists
-- ============================================================
CREATE TABLE Wishlist (
    wishlist_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES Users(user_id),
    wishlist_category_id UUID REFERENCES WishlistCategory(wishlist_category_id),
    name VARCHAR(250) NOT NULL,
    description VARCHAR(500),
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Items in a wishlist
-- ============================================================
CREATE TABLE WishlistItem (
    wishlist_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wishlist_id UUID NOT NULL REFERENCES Wishlist(wishlist_id),
    listing_id UUID NOT NULL REFERENCES Listing(listing_id),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- RATINGS AND REVIEWS
-- Allows guests and hosts to rate listings and profiles
-- ============================================================

-- ============================================================
-- Ratings given by a reviewer for a reservation
-- ============================================================
CREATE TABLE Rating (
    rating_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID REFERENCES Reservation(reservation_id),
    reviewer_profile_id UUID REFERENCES Profile(profile_id),
    rating_value INT CHECK (rating_value >= 0 AND rating_value <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Many-to-many relation linking ratings to listings
-- ============================================================
CREATE TABLE RatingListing (
    rating_id UUID REFERENCES Rating(rating_id),
    listing_id UUID REFERENCES Listing(listing_id),
    PRIMARY KEY (rating_id, listing_id)
);

-- ============================================================
-- Many-to-many relation linking ratings to guest profiles
-- ============================================================
CREATE TABLE RatingGuest (
    rating_id UUID REFERENCES Rating(rating_id),
    guest_profile_id UUID REFERENCES Profile(profile_id),
    PRIMARY KEY (rating_id, guest_profile_id)
);

-- ============================================================
-- Many-to-many relation linking ratings to host profiles
-- ============================================================
CREATE TABLE RatingHost (
    rating_id UUID REFERENCES Rating(rating_id),
    host_profile_id UUID REFERENCES Profile(profile_id),
    PRIMARY KEY (rating_id, host_profile_id)
);

-- ============================================================
-- RATING SUMMARIES
-- Stores aggregate rating data for profiles and listings
-- ============================================================

-- ============================================================
-- Aggregated rating info for a profile (guest or host)
-- ============================================================
CREATE TABLE ProfileRatingSummary (
    profile_rating_summary_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID REFERENCES Profile(profile_id),
    rating_count INT NOT NULL DEFAULT 0,
    rating_sum INT NOT NULL DEFAULT 0,
    avg_rating DECIMAL(5,2) DEFAULT 0
);

-- ============================================================
-- Aggregated rating info for a listing
-- ============================================================
CREATE TABLE ListingRatingSummary (
    listing_rating_summary_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID REFERENCES Listing(listing_id),
    rating_count INT NOT NULL DEFAULT 0,
    rating_sum INT NOT NULL DEFAULT 0,
    avg_rating DECIMAL(5,2) DEFAULT 0
);
