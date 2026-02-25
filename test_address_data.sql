-- ============================================================
-- ADDRESS STRUCTURE TEST SCRIPT
-- This section validates integrity and relationships for:
-- Continent -> Country -> City -> Address -> AddressRole -> ProfileAddress
-- ============================================================



-- ============================================================
-- CONTINENT TABLE TESTS
-- ============================================================

-- Test 1: Verify continents were inserted
SELECT COUNT(*) AS total_continents
FROM Continent;

-- Test 2: Ensure continent names are unique
SELECT name, COUNT(*)
FROM Continent
GROUP BY name
HAVING COUNT(*) > 1;



-- ============================================================
-- COUNTRY TABLE TESTS
-- ============================================================

-- Test 1: Verify countries exist
SELECT COUNT(*) AS total_countries
FROM Country;

-- Test 2: Ensure every country has a valid continent
SELECT c.country_id, c.name
FROM Country c
LEFT JOIN Continent ct ON ct.continent_id = c.continent_id
WHERE ct.continent_id IS NULL;

-- Test 3: Ensure ISO codes are not empty
SELECT *
FROM Country
WHERE iso_code IS NULL OR iso_code = '';



-- ============================================================
-- CITY TABLE TESTS
-- ============================================================

-- Test 1: Verify cities exist
SELECT COUNT(*) AS total_cities
FROM City;

-- Test 2: Ensure every city belongs to a valid country
SELECT city_id, name
FROM City c
LEFT JOIN Country co ON co.country_id = c.country_id
WHERE co.country_id IS NULL;



-- ============================================================
-- ADDRESS TABLE TESTS
-- ============================================================

-- Test 1: Verify addresses inserted
SELECT COUNT(*) AS total_addresses
FROM Address;

-- Test 2: Ensure every address has valid city and country
SELECT a.address_id
FROM Address a
LEFT JOIN City c ON c.city_id = a.city_id
LEFT JOIN Country co ON co.country_id = a.country_id
WHERE c.city_id IS NULL OR co.country_id IS NULL;

-- Test 3: Check required fields
SELECT *
FROM Address
WHERE address_line_1 IS NULL
   OR state_province IS NULL
   OR postal_code IS NULL;



-- ============================================================
-- ADDRESS ROLE TABLE TESTS
-- ============================================================

-- Test 1: Verify roles inserted
SELECT *
FROM AddressRole;

-- Test 2: Ensure role names are unique
SELECT name, COUNT(*)
FROM AddressRole
GROUP BY name
HAVING COUNT(*) > 1;

-- Test 3: Ensure "Primary Residence" role exists
SELECT *
FROM AddressRole
WHERE name = 'Primary Residence';



-- ============================================================
-- PROFILE ADDRESS TESTS
-- Many-to-many between Profile and Address
-- ============================================================

-- Test 1: Ensure every profile has a Primary Residence
SELECT p.profile_id
FROM Profile p
LEFT JOIN ProfileAddress pa ON pa.profile_id = p.profile_id
LEFT JOIN AddressRole ar ON ar.address_role_id = pa.address_role_id
WHERE ar.name = 'Primary Residence'
GROUP BY p.profile_id
HAVING COUNT(ar.address_role_id) = 0;

-- Test 2: Ensure no duplicate address-role per profile
SELECT address_id, profile_id, address_role_id, COUNT(*)
FROM ProfileAddress
GROUP BY address_id, profile_id, address_role_id
HAVING COUNT(*) > 1;

-- Test 3: Ensure valid FK relationships
SELECT pa.*
FROM ProfileAddress pa
LEFT JOIN Address a ON a.address_id = pa.address_id
LEFT JOIN Profile p ON p.profile_id = pa.profile_id
LEFT JOIN AddressRole ar ON ar.address_role_id = pa.address_role_id
WHERE a.address_id IS NULL
   OR p.profile_id IS NULL
   OR ar.address_role_id IS NULL;



-- ============================================================
-- BUSINESS RULE TESTS
-- Guests must have Primary Residence
-- Hosts may later have Business Address
-- ============================================================

-- Test 1: Guests missing Primary Residence
SELECT u.email
FROM Users u
JOIN UserRole ur ON ur.user_id = u.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN Profile p ON p.user_id = u.user_id
LEFT JOIN ProfileAddress pa ON pa.profile_id = p.profile_id
LEFT JOIN AddressRole ar ON ar.address_role_id = pa.address_role_id
WHERE r.role_type = 'guest'
AND ar.name <> 'Primary Residence'
GROUP BY u.email;

-- Test 2: Hosts without any address (should be rare)
SELECT u.email
FROM Users u
JOIN UserRole ur ON ur.user_id = u.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN Profile p ON p.user_id = u.user_id
LEFT JOIN ProfileAddress pa ON pa.profile_id = p.profile_id
WHERE r.role_type = 'host'
AND pa.address_id IS NULL;
