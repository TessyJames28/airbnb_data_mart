-- ============================================================
-- USER STRUCTURE TEST SCRIPT
-- This section validates integrity and relationships for:
-- Users -> Profile -> Role -> Social -> Language
-- ============================================================



-- ============================================================
-- USERS TABLE TESTS
-- ============================================================

-- Test 1: Verify users were inserted
SELECT COUNT(*) AS total_users
FROM Users;

-- Test 2: Ensure email uniqueness constraint works
SELECT email, COUNT(*)
FROM Users
GROUP BY email
HAVING COUNT(*) > 1;

-- Test 3: Check active users
SELECT user_id, email
FROM Users
WHERE is_active = TRUE;



-- ============================================================
-- PROFILE TABLE TESTS
-- ============================================================

-- Test 1: Ensure every user has exactly one profile
SELECT u.user_id
FROM Users u
LEFT JOIN Profile p ON p.user_id = u.user_id
WHERE p.profile_id IS NULL;

-- Test 2: Verify one-to-one constraint
SELECT user_id, COUNT(*)
FROM Profile
GROUP BY user_id
HAVING COUNT(*) > 1;



-- ============================================================
-- ROLE TABLE TESTS
-- ============================================================

-- Test 1: Verify roles inserted (guest, host)
SELECT *
FROM Role;

-- Test 2: Ensure role types are unique
SELECT role_type, COUNT(*)
FROM Role
GROUP BY role_type
HAVING COUNT(*) > 1;



-- ============================================================
-- USERROLE TABLE TESTS
-- Many-to-many between Users and Role
-- ============================================================

-- Test 1: Check users with multiple roles
SELECT u.email, COUNT(ur.role_id) AS role_count
FROM Users u
JOIN UserRole ur ON ur.user_id = u.user_id
GROUP BY u.email
HAVING COUNT(ur.role_id) > 1;

-- Test 2: Ensure no duplicate role assignment
SELECT user_id, role_id, COUNT(*)
FROM UserRole
GROUP BY user_id, role_id
HAVING COUNT(*) > 1;



-- ============================================================
-- SOCIAL TABLE TESTS
-- ============================================================

-- Test 1: Verify social platforms inserted
SELECT *
FROM Social;

-- Test 2: Ensure unique platform names
SELECT social_platform, COUNT(*)
FROM Social
GROUP BY social_platform
HAVING COUNT(*) > 1;



-- ============================================================
-- PROFILE SOCIAL TESTS
-- Many-to-many between Profile and Social
-- ============================================================

-- Test 1: Ensure every profile has at least one social
SELECT p.profile_id
FROM Profile p
LEFT JOIN ProfileSocial ps ON ps.profile_id = p.profile_id
WHERE ps.social_id IS NULL;

-- Test 2: Check primary social per profile (should be max 1)
SELECT profile_id, COUNT(*)
FROM ProfileSocial
WHERE is_primary = TRUE
GROUP BY profile_id
HAVING COUNT(*) > 1;



-- ============================================================
-- LANGUAGE TABLE TESTS
-- ============================================================

-- Test 1: Verify languages inserted
SELECT COUNT(*) AS total_languages
FROM Language;

-- Test 2: Ensure ISO codes are unique
SELECT iso_code, COUNT(*)
FROM Language
GROUP BY iso_code
HAVING COUNT(*) > 1;



-- ============================================================
-- HOST LANGUAGE TESTS
-- Only profiles with host role should exist here
-- ============================================================

-- Test 1: Ensure only hosts have host languages
SELECT hl.profile_id
FROM HostLanguage hl
LEFT JOIN UserRole ur ON ur.user_id = (
    SELECT user_id FROM Profile WHERE profile_id = hl.profile_id
)
LEFT JOIN Role r ON r.role_id = ur.role_id
WHERE r.role_type <> 'host';

-- Test 2: Check proficiency level validity
SELECT *
FROM HostLanguage
WHERE proficiency_level NOT IN ('native','fluent','beginner');

-- Test 3: Ensure no duplicate language per host
SELECT profile_id, language_id, COUNT(*)
FROM HostLanguage
GROUP BY profile_id, language_id
HAVING COUNT(*) > 1;
