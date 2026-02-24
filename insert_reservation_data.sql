i-- ============================================================
-- BOOKING / RESERVATION DATA INSERT SCRIPT
-- This file inserts realistic test data for bookings,
-- reservations, payments, payouts, refunds and billing.
--
-- RULES:
-- 1. Only users with role = 'guest' can create bookings
-- 2. Listings must belong to hosts
-- 3. Reservations come from confirmed bookings
-- 4. Payouts go only to hosts
-- 5. Billing addresses linked to payment
-- ============================================================



-- ============================================================
-- CURRENCY
-- Insert supported currencies (20+ records)
-- ============================================================
INSERT INTO Currency (code, name, symbol)
VALUES
('USD','US Dollar','$'),
('EUR','Euro','€'),
('GBP','British Pound','£'),
('NGN','Naira','₦'),
('CAD','Canadian Dollar','$'),
('AUD','Australian Dollar','$'),
('JPY','Yen','¥'),
('CNY','Yuan','¥'),
('INR','Indian Rupee','₹'),
('CHF','Swiss Franc','CHF'),
('SEK','Swedish Krona','kr'),
('NOK','Norwegian Krone','kr'),
('DKK','Danish Krone','kr'),
('ZAR','Rand','R'),
('GHS','Cedi','₵'),
('KES','Shilling','KSh'),
('BRL','Real','R$'),
('MXN','Peso','$'),
('TRY','Lira','₺'),
('KRW','Won','₩');



-- ============================================================
-- PAYOUT METHODS
-- ============================================================
INSERT INTO PayoutMethod (name)
VALUES
('Bank Transfer'),
('PayPal'),
('Stripe'),
('Payoneer');



-- ============================================================
-- BOOKINGS
-- Only profiles with role = 'guest'
-- Listings must exist
-- ============================================================
INSERT INTO Booking (
    listing_id,
    guest_id,
    host_id,
    requested_start_date,
    requested_end_date,
    num_of_guests,
    status,
    total_amount,
    currency_id
)
SELECT
    l.listing_id,
    guest.profile_id,
    l.host_id,
    CURRENT_DATE + (random()*20)::int,
    CURRENT_DATE + (random()*40)::int,
    2,
    'confirmed',
    200 + (random()*400)::int,
    c.currency_id
FROM Listing l
JOIN Profile guest ON guest.profile_id <> l.host_id
JOIN UserRole ur ON ur.user_id = guest.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN Currency c ON c.code = 'USD'
WHERE r.role_type = 'guest'
LIMIT 20;



-- ============================================================
-- RESERVATIONS
-- Only for confirmed bookings
-- ============================================================
INSERT INTO Reservation (
    listing_id,
    guest_id,
    start_date,
    end_date
)
SELECT
    b.listing_id,
    b.guest_id,
    b.requested_start_date,
    b.requested_end_date
FROM Booking b
WHERE b.status = 'confirmed'
LIMIT 20;



-- ============================================================
-- PAYMENTS
-- Payments made by guests
-- ============================================================
INSERT INTO Payment (
    booking_id,
    guest_id,
    amount,
    currency_id,
    payment_status,
    payment_method,
    payment_date,
    card_last_four,
    card_token
)
SELECT
    b.booking_id,
    b.guest_id,
    b.total_amount,
    b.currency_id,
    'successful',
    'credit_card',
    CURRENT_TIMESTAMP,
    '1234',
    md5(random()::text)
FROM Booking b
LIMIT 20;



-- ============================================================
-- PAYOUT ACCOUNTS
-- Only hosts can have payout accounts
-- ============================================================
INSERT INTO PayoutAccount (
    host_id,
    payout_method_id,
    account_name,
    account_identifier,
    currency_id
)
SELECT
    p.profile_id,
    pm.payout_method_id,
    'Host Account ' || row_number() OVER (),
    md5(random()::text),
    c.currency_id
FROM Profile p
JOIN UserRole ur ON ur.user_id = p.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN PayoutMethod pm ON pm.name = 'Bank Transfer'
JOIN Currency c ON c.code = 'USD'
WHERE r.role_type = 'host'
LIMIT 20;



-- ============================================================
-- PAYOUTS
-- Payouts after reservation
-- ============================================================
INSERT INTO Payout (
    reservation_id,
    host_id,
    payout_account_id,
    amount,
    currency_id,
    payout_status,
    payout_date
)
SELECT
    r.reservation_id,
    l.host_id,
    pa.payout_account_id,
    150 + (random()*300)::int,
    c.currency_id,
    'paid',
    CURRENT_TIMESTAMP
FROM Reservation r
JOIN Listing l ON l.listing_id = r.listing_id
JOIN PayoutAccount pa ON pa.host_id = l.host_id
JOIN Currency c ON c.code = 'USD'
LIMIT 20;



-- ============================================================
-- REFUND REASONS
-- ============================================================
INSERT INTO RefundReason (code, description, default_refund_type, initiated_by)
VALUES
('HOST_CANCEL','Host cancelled booking','full','host'),
('GUEST_CANCEL','Guest cancelled early','partial','guest'),
('OVERBOOKED','Listing double booked','full','system'),
('PAYMENT_FAIL','Payment failure','full','system'),
('SERVICE_ISSUE','Listing issue','partial','guest');



-- ============================================================
-- REFUNDS
-- Some bookings refunded
-- ============================================================
INSERT INTO Refund (
    payment_id,
    booking_id,
    amount,
    currency_id,
    refund_reason_id,
    processed_at,
    refund_type
)
SELECT
    p.payment_id,
    p.booking_id,
    p.amount * 0.5,
    p.currency_id,
    rr.refund_reason_id,
    CURRENT_TIMESTAMP,
    'partial'
FROM Payment p
JOIN RefundReason rr ON rr.code = 'GUEST_CANCEL'
LIMIT 10;



-- ============================================================
-- BILLING ADDRESS
-- Each payment has billing address
-- ============================================================
INSERT INTO BillingAddress (
    address_id,
    profile_id,
    payment_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
    a.address_id,
    p.guest_id,
    pay.payment_id,
    ar.address_role_id,
    TRUE,
    CURRENT_DATE
FROM Payment pay
JOIN Booking p ON p.booking_id = pay.booking_id
JOIN Address a ON TRUE
JOIN AddressRole ar ON ar.name = 'Billing'
LIMIT 20;



-- ============================================================
-- BUSINESS ADDRESS
-- Hosts payout business address
-- ============================================================
INSERT INTO BusinessAddress (
    address_id,
    profile_id,
    payment_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
    a.address_id,
    pa.host_id,
    pay.payment_id,
    ar.address_role_id,
    TRUE,
    CURRENT_DATE
FROM PayoutAccount pa
JOIN Payment pay ON TRUE
JOIN Address a ON TRUE
JOIN AddressRole ar ON ar.name = 'Business'
LIMIT 20;
