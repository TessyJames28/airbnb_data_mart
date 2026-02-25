-- ============================================================
-- BOOKING / RESERVATION STRUCTURE TEST SCRIPT
-- Validates integrity for:
-- Booking -> Reservation -> Payment -> Payout -> Refund -> Address relations
-- ============================================================

-- ============================================================
-- CURRENCY TESTS
-- ============================================================

-- Test 1: Ensure at least one active currency exists
SELECT COUNT(*) AS total_currencies
FROM Currency
WHERE is_active = TRUE;

-- Test 2: Ensure no duplicate codes
SELECT code, COUNT(*)
FROM Currency
GROUP BY code
HAVING COUNT(*) > 1;



-- ============================================================
-- BOOKING TESTS
-- ============================================================

-- Test 1: Ensure bookings exist
SELECT COUNT(*) AS total_bookings
FROM Booking;

-- Test 2: Every booking must reference valid listing
SELECT b.booking_id
FROM Booking b
LEFT JOIN Listing l ON l.listing_id = b.listing_id
WHERE l.listing_id IS NULL;

-- Test 3: Every booking must reference valid guest and host profiles
SELECT b.booking_id
FROM Booking b
LEFT JOIN Profile g ON g.profile_id = b.guest_id
LEFT JOIN Profile h ON h.profile_id = b.host_id
WHERE g.profile_id IS NULL OR h.profile_id IS NULL;

-- Test 4: Booking dates must be logical (start < end)
SELECT *
FROM Booking
WHERE requested_start_date >= requested_end_date;

-- Test 5: Total amount positive
SELECT *
FROM Booking
WHERE total_amount <= 0;

-- Test 6: Status must be valid enum
SELECT *
FROM Booking
WHERE status NOT IN ('pending','confirmed','cancelled','rejected');



-- ============================================================
-- RESERVATION TESTS
-- ============================================================

-- Test 1: Ensure reservations exist
SELECT COUNT(*) AS total_reservations
FROM Reservation;

-- Test 2: Every reservation must reference a valid listing and guest
SELECT r.reservation_id
FROM Reservation r
LEFT JOIN Listing l ON l.listing_id = r.listing_id
LEFT JOIN Profile g ON g.profile_id = r.guest_id
WHERE l.listing_id IS NULL OR g.profile_id IS NULL;

-- Test 3: Dates must be logical
SELECT *
FROM Reservation
WHERE start_date >= end_date;

-- Test 4: Check actual check-in/out within booked period
SELECT *
FROM Reservation
WHERE (actual_checkin IS NOT NULL AND actual_checkin < start_date)
   OR (actual_checkout IS NOT NULL AND actual_checkout > end_date);



-- ============================================================
-- PAYMENT TESTS
-- ============================================================

-- Test 1: Ensure payments exist
SELECT COUNT(*) AS total_payments
FROM Payment;

-- Test 2: Each payment references valid booking and guest
SELECT p.payment_id
FROM Payment p
LEFT JOIN Booking b ON b.booking_id = p.booking_id
LEFT JOIN Profile g ON g.profile_id = p.guest_id
WHERE (p.booking_id IS NOT NULL AND b.booking_id IS NULL)
   OR g.profile_id IS NULL;

-- Test 3: Payment amounts positive
SELECT *
FROM Payment
WHERE amount <= 0;

-- Test 4: Payment status valid
SELECT *
FROM Payment
WHERE payment_status NOT IN ('pending','successful','failed','refunded');

-- Test 5: Payment method valid
SELECT *
FROM Payment
WHERE payment_method NOT IN ('credit_card');



-- ============================================================
-- PAYOUT METHOD & ACCOUNT TESTS
-- ============================================================

-- Test 1: Ensure payout methods exist and active
SELECT *
FROM PayoutMethod
WHERE is_active = FALSE;

-- Test 2: Ensure payout accounts exist and reference valid host & method
SELECT pa.*
FROM PayoutAccount pa
LEFT JOIN Profile p ON p.profile_id = pa.host_id
LEFT JOIN PayoutMethod pm ON pm.payout_method_id = pa.payout_method_id
WHERE p.profile_id IS NULL OR pm.payout_method_id IS NULL;



-- ============================================================
-- PAYOUT TESTS
-- ============================================================

-- Test 1: Ensure payouts reference valid reservation and host
SELECT po.*
FROM Payout po
LEFT JOIN Reservation r ON r.reservation_id = po.reservation_id
LEFT JOIN Profile p ON p.profile_id = po.host_id
WHERE (po.reservation_id IS NOT NULL AND r.reservation_id IS NULL)
   OR p.profile_id IS NULL;

-- Test 2: Amount positive
SELECT *
FROM Payout
WHERE amount <= 0;

-- Test 3: Status valid
SELECT *
FROM Payout
WHERE payout_status NOT IN ('pending','paid','failed');



-- ============================================================
-- REFUND REASON & REFUND TESTS
-- ============================================================

-- Test 1: Ensure refund reasons exist and active
SELECT *
FROM RefundReason
WHERE is_active = FALSE;

-- Test 2: Ensure refunds reference valid payment or booking
SELECT r.*
FROM Refund r
LEFT JOIN Payment p ON p.payment_id = r.payment_id
LEFT JOIN Booking b ON b.booking_id = r.booking_id
WHERE (r.payment_id IS NOT NULL AND p.payment_id IS NULL)
   AND (r.booking_id IS NOT NULL AND b.booking_id IS NULL);

-- Test 3: Refund amounts positive
SELECT *
FROM Refund
WHERE amount <= 0;

-- Test 4: Refund type valid
SELECT *
FROM Refund
WHERE refund_type NOT IN ('full','partial');



-- ============================================================
-- BILLING & BUSINESS ADDRESS RELATIONS TESTS
-- ============================================================

-- Test 1: Ensure billing addresses reference valid profile, payment, address, role
SELECT ba.*
FROM BillingAddress ba
LEFT JOIN Profile p ON p.profile_id = ba.profile_id
LEFT JOIN Payment py ON py.payment_id = ba.payment_id
LEFT JOIN Address a ON a.address_id = ba.address_id
LEFT JOIN AddressRole ar ON ar.address_role_id = ba.address_role_id
WHERE p.profile_id IS NULL
   OR py.payment_id IS NULL
   OR a.address_id IS NULL
   OR ar.address_role_id IS NULL;

-- Test 2: Ensure business addresses reference valid profile, payment, address, role
SELECT ba.*
FROM BusinessAddress ba
LEFT JOIN Profile p ON p.profile_id = ba.profile_id
LEFT JOIN Payment py ON py.payment_id = ba.payment_id
LEFT JOIN Address a ON a.address_id = ba.address_id
LEFT JOIN AddressRole ar ON ar.address_role_id = ba.address_role_id
WHERE p.profile_id IS NULL
   OR py.payment_id IS NULL
   OR a.address_id IS NULL
   OR ar.address_role_id IS NULL;

-- Test 3: Check duplicates in billing/business addresses
SELECT address_id, profile_id, payment_id, address_role_id, COUNT(*)
FROM BillingAddress
GROUP BY address_id, profile_id, payment_id, address_role_id
HAVING COUNT(*) > 1;

SELECT address_id, profile_id, payment_id, address_role_id, COUNT(*)
FROM BusinessAddress
GROUP BY address_id, profile_id, payment_id, address_role_id
HAVING COUNT(*) > 1;



-- ============================================================
-- BUSINESS RULE TESTS
-- ============================================================

-- Test 1: Booking guests must not exceed listing capacity
SELECT b.booking_id
FROM Booking b
JOIN Listing l ON l.listing_id = b.listing_id
WHERE b.num_of_guests > l.guest_capacity;

-- Test 2: Booking dates must be future-dated (optional)
SELECT *
FROM Booking
WHERE requested_start_date < CURRENT_DATE;

-- Test 3: Payout amount must match booking total minus fees (if applicable)
-- (This is optional and can be adjusted once fee structure exists)
SELECT po.*
FROM Payout po
JOIN Reservation r ON r.reservation_id = po.reservation_id
JOIN Booking b ON b.booking_id = r.reservation_id
WHERE po.amount <= 0;
