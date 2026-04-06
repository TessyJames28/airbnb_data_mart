-- ============================================================
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
\echo 'Inserting into PayoutMethod'
INSERT INTO PayoutMethod (name)
VALUES
('Bank Transfer'),
('PayPal'),
('Stripe'),
('Payoneer'),
('Venmo'),
('Cash App'),
('Zelle'),
('Skrill'),
('Google Pay'),
('Apple Pay'),
('Wise'),
('Revolut'),
('Direct Deposit'),
('ACH Transfer'),
('Wire Transfer'),
('Check'),
('Cryptocurrency'),
('Alipay'),
('WeChat Pay'),
('Payone');



-- ============================================================
-- BOOKINGS
-- Only profiles with role = 'guest'
-- Listings must exist
-- ============================================================
\echo 'Inserting into Booking'
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
    -- Assign booking status randomly with weighted probability
    CASE
        WHEN random() < 0.7 THEN 'confirmed'::booking_status_enum   -- 70% confirmed
        WHEN random() < 0.85 THEN 'pending'::booking_status_enum    -- 15% pending
        WHEN random() < 0.95 THEN 'cancelled'::booking_status_enum   -- 10% canceled
        ELSE 'rejected'::booking_status_enum                        -- 5% rejected
    END AS status,
    200 + (random()*400)::int,
    c.currency_id
FROM Listing l
JOIN Profile guest ON guest.profile_id <> l.host_id
JOIN UserRole ur ON ur.user_id = guest.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN Currency c ON c.code = 'USD'
WHERE r.role_type = 'guest';


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
WHERE b.status = 'confirmed';



-- ============================================================
-- PAYMENTS
-- Payments made by guests
-- ============================================================
-- INSERT INTO Payment (
--     booking_id,
--     guest_id,
--     amount,
--     currency_id,
--     payment_status,
--     payment_method,
--     payment_date,
--     card_last_four,
--     card_token
-- )
-- SELECT
--     b.booking_id,
--     b.guest_id,
--     b.total_amount,
--     b.currency_id,
--     'successful',
--     'credit_card',
--     CURRENT_TIMESTAMP,
--     '1234',
--     md5(random()::text)
-- FROM Booking b
-- LIMIT 20;

-- ============================================================
-- PAYMENTS
-- Payments made by guests, status based on booking
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
    -- Assign payment_status based on booking.status
    CASE
        WHEN b.status = 'confirmed' THEN 'successful'::payment_status_enum
        WHEN b.status = 'pending' THEN 'pending'::payment_status_enum
        WHEN b.status = 'cancelled' THEN 'refunded'::payment_status_enum
        -- Optional: if you want a few failed payments randomly
        WHEN random() < 0.02 THEN 'failed'::payment_status_enum
        ELSE 'pending'::payment_status_enum  -- fallback
    END AS payment_status,
    'credit_card' AS payment_method,
    CURRENT_TIMESTAMP AS payment_date,
    '1234' AS card_last_four,
    md5(random()::text) AS card_token
FROM Booking b
ORDER BY random(); -- shuffle for a more natural distribution



-- ============================================================
-- PAYOUT ACCOUNTS
-- Only hosts can have payout accounts
-- ============================================================
\echo 'Inserting into PayoutAccount'
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
CROSS JOIN Currency c
CROSS JOIN LATERAL (
    SELECT payout_method_id
    FROM PayoutMethod
    ORDER BY random()
    LIMIT (floor(random()*2)+2)  -- randomly 2 or 3 methods
) pm
WHERE r.role_type = 'host'
AND c.code = 'USD';
-- INSERT INTO PayoutAccount (
--     host_id,
--     payout_method_id,
--     account_name,
--     account_identifier,
--     currency_id
-- )
-- SELECT
--     p.profile_id,
--     pm.payout_method_id,
--     'Host Account ' || row_number() OVER (),
--     md5(random()::text),
--     c.currency_id
-- FROM Profile p
-- JOIN UserRole ur ON ur.user_id = p.user_id
-- JOIN Role r ON r.role_id = ur.role_id
-- JOIN PayoutMethod pm ON pm.name = 'Bank Transfer'
-- JOIN Currency c ON c.code = 'USD'
-- WHERE r.role_type = 'host'
-- LIMIT 20;



-- ============================================================
-- PAYOUTS
-- Payouts after reservation
-- ============================================================
\echo 'Inserting into Payout'
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
    150 + (random()*300)::int,  -- random payout amount
    c.currency_id,
    -- Assign payout status randomly with weighted probability
    CASE
        WHEN random() < 0.8 THEN 'paid'::payout_status_enum   -- 80% paid
        WHEN random() < 0.95 THEN 'pending'::payout_status_enum -- 15% pending
        ELSE 'failed'::payout_status_enum                       -- 5% failed
    END AS payout_status,
    CURRENT_TIMESTAMP
FROM Reservation r
JOIN Listing l ON l.listing_id = r.listing_id
JOIN PayoutAccount pa ON pa.host_id = l.host_id
JOIN Currency c ON c.code = 'USD';  -- only confirmed reservations
-- INSERT INTO Payout (
--     reservation_id,
--     host_id,
--     payout_account_id,
--     amount,
--     currency_id,
--     payout_status,
--     payout_date
-- )
-- SELECT
--     r.reservation_id,
--     l.host_id,
--     pa.payout_account_id,
--     150 + (random()*300)::int,
--     c.currency_id,
--     -- Assign refund status randomly with weighted probability
--     CASE
--         WHEN random() < 0.8 THEN 'paid'::payout_status_enum   -- 80% confirmed
--         WHEN random() < 0.95 THEN 'pending'::payout_status_enum    -- 15% pending
--         ELSE 'failed'::payout_status_enum                          -- 5% rejected
--     END AS payout_status,
--     CURRENT_TIMESTAMP
-- FROM Reservation r
-- JOIN Listing l ON l.listing_id = r.listing_id
-- JOIN PayoutAccount pa ON pa.host_id = l.host_id
-- JOIN Currency c ON c.code = 'USD';



-- ============================================================
-- REFUND REASONS
-- ============================================================
\echo 'Inserting into RefundReason'
INSERT INTO RefundReason (code, description, default_refund_type, initiated_by)
VALUES
('HOST_CANCEL','Host cancelled booking','full','host'),
('GUEST_CANCEL','Guest cancelled early','partial','guest'),
('OVERBOOKED','Listing double booked','full','system'),
('PAYMENT_FAIL','Payment failure','full','system'),
('SERVICE_ISSUE','Listing issue','partial','guest'),
('LATE_CHECKIN', 'Guest arrived but check-in was delayed', 'partial', 'host'),
('EARLY_CHECKOUT', 'Guest checked out earlier than planned', 'partial', 'guest'),
('DIRTY_LISTING', 'Listing not clean on arrival', 'full', 'guest'),
('AMENITY_MISSING', 'Promised amenity not available', 'partial', 'guest'),
('NO_SHOW_HOST', 'Host did not show up', 'full', 'guest'),
('NO_SHOW_GUEST', 'Guest did not show up', 'full', 'host'),
('FACILITY_DAMAGE', 'Guest damaged property', 'partial', 'host'),
('TECHNICAL_ISSUE', 'System error prevented booking', 'full', 'system'),
('DOUBLE_CHARGE', 'Guest charged twice', 'full', 'system'),
('PRICE_MISMATCH', 'Price discrepancy found', 'partial', 'system'),
('CANCELLATION_POLICY', 'Host violated cancellation policy', 'full', 'guest'),
('FORCE_MAJEURE', 'Natural disaster or emergency', 'full', 'system'),
('MISLEADING_LISTING', 'Listing description inaccurate', 'full', 'guest'),
('BOOKING_ERROR', 'System booking mistake', 'full', 'system'),
('PARTIAL_REFUND_REQUEST', 'Guest requested partial refund', 'partial', 'guest');



-- ============================================================
-- REFUNDS
-- Some bookings refunded
-- ============================================================
-- INSERT INTO Refund (
--     payment_id,
--     booking_id,
--     amount,
--     currency_id,
--     refund_reason_id,
--     processed_at,
--     refund_type
-- )
-- SELECT
--     p.payment_id,
--     p.booking_id,
--     p.amount * 0.5,
--     p.currency_id,
--     rr.refund_reason_id,
--     CURRENT_TIMESTAMP,
--     'partial'
-- FROM Payment p
-- JOIN RefundReason rr ON rr.code = 'GUEST_CANCEL'
-- LIMIT 10;

-- ============================================================
-- REFUNDS
-- Some bookings refunded (canceled bookings only)
-- ============================================================
\echo 'Inserting into Refund'
INSERT INTO Refund (
    payment_id,
    booking_id,
    amount,
    currency_id,
    refund_reason_id,
    processed_at,
    refund_type,
    refund_status
)
SELECT
    p.payment_id,
    p.booking_id,
    -- Calculate amount based on the refund type (randomized 50/50 chance)
    CASE
        WHEN random() < 0.5 AND rr.default_refund_type = 'partial' THEN p.amount * 0.5
        WHEN rr.default_refund_type = 'full' THEN p.amount
        ELSE p.amount  -- fallback: treat as full
    END AS amount,
    p.currency_id,
    rr.refund_reason_id,
    CURRENT_TIMESTAMP,
    -- Randomize refund type for variety, but cast to enum
    CASE
        WHEN random() < 0.7 THEN rr.default_refund_type::refund_type_enum
        ELSE CASE 
            WHEN rr.default_refund_type = 'partial' THEN 'full'::refund_type_enum
            ELSE 'partial'::refund_type_enum
        END
    END AS refund_type,
    -- Refund status randomly weighted
    CASE
        WHEN random() < 0.8 THEN 'processed'::refund_status_enum
        WHEN random() < 0.95 THEN 'pending'::refund_status_enum
        ELSE 'failed'::refund_status_enum
    END AS refund_status
FROM Payment p
JOIN Booking b ON b.booking_id = p.booking_id
JOIN LATERAL (
    SELECT rr2.refund_reason_id, rr2.default_refund_type
    FROM RefundReason rr2
    ORDER BY random()
    LIMIT 1
) rr ON true
WHERE b.status = 'cancelled';
-- INSERT INTO Refund (
--     payment_id,
--     booking_id,
--     amount,
--     currency_id,
--     refund_reason_id,
--     processed_at,
--     refund_type,
--     refund_status
-- )
-- SELECT
--     p.payment_id,
--     p.booking_id,
--     -- Refund amount depends on default type in reason
--     CASE
--         WHEN rr.default_refund_type = 'partial' THEN p.amount * 0.5
--         ELSE p.amount
--     END AS amount,
--     p.currency_id,
--     rr.refund_reason_id,
--     CURRENT_TIMESTAMP,
--     rr.default_refund_type AS refund_type,
--     -- Assign refund status randomly with weighted probability
--     CASE
--         WHEN random() < 0.8 THEN 'processed'::refund_status_enum   -- 80% confirmed
--         WHEN random() < 0.95 THEN 'pending'::refund_status_enum    -- 15% pending
--         ELSE 'failed'::refund_status_enum                          -- 5% rejected
--     END AS refund_status
-- FROM Payment p
-- JOIN Booking b ON b.booking_id = p.booking_id
-- -- Only canceled bookings get refunds
-- JOIN RefundReason rr ON rr.code IN ('HOST_CANCEL', 'GUEST_CANCEL', 'OVERBOOKED', 'SERVICE_ISSUE')
-- WHERE b.status = 'cancelled'
-- -- Randomly assign refund reason to canceled bookings
-- ORDER BY random();



-- ============================================================
-- BILLING ADDRESS
-- Each payment has billing address
-- ============================================================
\echo 'Inserting into BillingAddress'
INSERT INTO BillingAddress (
    address_id,
    profile_id,
    payment_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
    a.address_id,         -- random address
    b.guest_id,           -- guest of the booking
    pay.payment_id,       -- current payment
    ar.address_role_id,   -- 'Billing' role
    TRUE,
    CURRENT_DATE
FROM Payment pay
JOIN Booking b ON b.booking_id = pay.booking_id
JOIN AddressRole ar ON ar.name = 'Billing'
JOIN LATERAL (
    SELECT a2.address_id
    FROM Address a2
    ORDER BY random()
    LIMIT 1
) a ON TRUE;
-- INSERT INTO BillingAddress (
--     address_id,
--     profile_id,
--     payment_id,
--     address_role_id,
--     is_active,
--     valid_from
-- )
-- SELECT
--     a.address_id,
--     p.guest_id,
--     pay.payment_id,
--     ar.address_role_id,
--     TRUE,
--     CURRENT_DATE
-- FROM Payment pay
-- JOIN Booking p ON p.booking_id = pay.booking_id
-- JOIN Address a ON TRUE
-- JOIN AddressRole ar ON ar.name = 'Billing'
-- LIMIT 20;



-- ============================================================
-- BUSINESS ADDRESS
-- Hosts payout business address
-- ============================================================
\echo 'Inserting into BusinessAddress'
INSERT INTO BusinessAddress (
    address_id,
    profile_id,
    payout_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
    a.address_id,        -- random address
    pa.host_id,          -- host of the payout account
    pay.payout_id,       -- current payout
    ar.address_role_id,  -- 'Business' role
    TRUE,
    CURRENT_DATE
FROM Payout pay
JOIN PayoutAccount pa ON pa.payout_account_id = pay.payout_account_id
JOIN AddressRole ar ON ar.name = 'Business'
JOIN LATERAL (
    SELECT a2.address_id
    FROM Address a2
    ORDER BY random()
    LIMIT 1
) a ON TRUE;

-- INSERT INTO BusinessAddress (
--     address_id,
--     profile_id,
--     payout_id,
--     address_role_id,
--     is_active,
--     valid_from
-- )
-- SELECT
--     a.address_id,
--     pa.host_id,
--     pay.payout_id,
--     ar.address_role_id,
--     TRUE,
--     CURRENT_DATE
-- FROM PayoutAccount pa
-- JOIN Payout pay ON TRUE
-- JOIN Address a ON TRUE
-- JOIN AddressRole ar ON ar.name = 'Business'
-- LIMIT 20;
