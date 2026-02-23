-- ============================================================
-- ENABLE UUID GENERATION
-- Ensures we can generate UUIDs for primary keys if not already enabled
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM TYPES
-- Defines all enum types for booking, payment, payout, and refund status tracking
-- ============================================================

-- ============================================================
-- Booking status tracking
-- ============================================================
CREATE TYPE booking_status_enum AS ENUM (
    'pending',
    'confirmed',
    'cancelled',
    'rejected'
);

-- ============================================================
-- Payment status tracking
-- ============================================================
CREATE TYPE payment_status_enum AS ENUM (
    'pending',
    'successful',
    'failed',
    'refunded'
);

-- ============================================================
-- Payment methods (extendable for future payment types)
-- ============================================================
CREATE TYPE payment_method_enum AS ENUM (
    'credit_card'
);

-- ============================================================
-- Payout status for hosts
-- ============================================================
CREATE TYPE payout_status_enum AS ENUM (
    'pending',
    'paid',
    'failed'
);

-- ============================================================
-- Refund types
-- ============================================================
CREATE TYPE refund_type_enum AS ENUM (
    'full',
    'partial'
);

-- ============================================================
-- Refund initiated by (guest, host, or system)
-- ============================================================
CREATE TYPE refund_initiated_by_enum AS ENUM (
    'guest',
    'host',
    'system'
);

-- ============================================================
-- CURRENCY
-- Stores supported currencies and their symbols
-- ============================================================
CREATE TABLE currency (
    currency_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(15) NOT NULL,
    name VARCHAR(30) NOT NULL,
    symbol VARCHAR(5),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- BOOKING
-- Represents a guest’s request for a listing
-- ============================================================
CREATE TABLE booking (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES Listing(listing_id),
    guest_id UUID NOT NULL REFERENCES Profile(profile_id),
    host_id UUID NOT NULL REFERENCES Profile(profile_id),
    requested_start_date DATE NOT NULL,
    requested_end_date DATE NOT NULL,
    num_of_guests INT NOT NULL,
    status booking_status_enum DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL,
    currency_id UUID REFERENCES currency(currency_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- RESERVATION
-- Represents confirmed stays based on a booking
-- ============================================================
CREATE TABLE reservation (
    reservation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES Listing(listing_id),
    guest_id UUID NOT NULL REFERENCES Profile(profile_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    actual_checkin DATE,
    actual_checkout DATE
);

-- ============================================================
-- PAYMENT
-- Records payments made by guests
-- ============================================================
CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES booking(booking_id),
    guest_id UUID NOT NULL REFERENCES Profile(profile_id),
    amount DECIMAL(12,2) NOT NULL,
    currency_id UUID REFERENCES currency(currency_id),
    payment_status payment_status_enum DEFAULT 'pending',
    payment_method payment_method_enum DEFAULT 'credit_card',
    payment_date TIMESTAMP,
    card_last_four VARCHAR(4),
    card_token VARCHAR(50)
);

-- ============================================================
-- PAYOUT METHOD
-- Methods for hosts to receive payouts
-- ============================================================
CREATE TABLE payout_method (
    payout_method_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- PAYOUT ACCOUNT
-- Accounts associated with payout methods for hosts
-- ============================================================
CREATE TABLE payout_account (
    payout_account_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id UUID NOT NULL REFERENCES Profile(profile_id),
    payout_method_id UUID REFERENCES payout_method(payout_method_id),
    account_name VARCHAR(200) NOT NULL,
    account_identifier VARCHAR(100) NOT NULL,
    currency_id UUID REFERENCES currency(currency_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- PAYOUT
-- Records payouts made to hosts
-- ============================================================
CREATE TABLE payout (
    payout_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID REFERENCES reservation(reservation_id),
    host_id UUID NOT NULL REFERENCES Profile(profile_id),
    payout_account_id UUID REFERENCES payout_account(payout_account_id),
    amount DECIMAL(12,2) NOT NULL,
    currency_id UUID REFERENCES currency(currency_id),
    payout_status payout_status_enum DEFAULT 'pending',
    payout_date TIMESTAMP
);

-- ============================================================
-- REFUND REASON
-- Stores reasons for refunds along with default types and initiators
-- ============================================================
CREATE TABLE refund_reason (
    refund_reason_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code CHAR(20) NOT NULL,
    description TEXT,
    default_refund_type refund_type_enum,
    initiated_by refund_initiated_by_enum,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- REFUND
-- Records refunds processed for payments or bookings
-- ============================================================
CREATE TABLE refund (
    refund_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES payment(payment_id),
    booking_id UUID REFERENCES booking(booking_id),
    amount DECIMAL(12,2) NOT NULL,
    currency_id UUID REFERENCES currency(currency_id),
    refund_reason_id UUID REFERENCES refund_reason(refund_reason_id),
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    refund_type refund_type_enum
);
