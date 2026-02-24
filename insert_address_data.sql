-- ============================================================
-- INSERT SAMPLE DATA FOR ADDRESS STRUCTURE
-- ============================================================

-- ============================================================
-- CONTINENTS
-- At least 6 real-world continents
-- ============================================================
INSERT INTO Continent (continent_id, name) VALUES
(uuid_generate_v4(), 'Africa'),
(uuid_generate_v4(), 'Europe'),
(uuid_generate_v4(), 'Asia'),
(uuid_generate_v4(), 'North America'),
(uuid_generate_v4(), 'South America'),
(uuid_generate_v4(), 'Oceania');



-- ============================================================
-- COUNTRIES
-- 20+ countries across continents
-- ============================================================
INSERT INTO Country (country_id, name, iso_code, continent_id)
SELECT uuid_generate_v4(), country_name, iso, continent_id
FROM (
VALUES
('Nigeria','NGA','Africa'),
('Ghana','GHA','Africa'),
('Kenya','KEN','Africa'),
('South Africa','ZAF','Africa'),
('Egypt','EGY','Africa'),

('France','FRA','Europe'),
('Germany','DEU','Europe'),
('Italy','ITA','Europe'),
('Spain','ESP','Europe'),
('Netherlands','NLD','Europe'),

('China','CHN','Asia'),
('Japan','JPN','Asia'),
('India','IND','Asia'),
('South Korea','KOR','Asia'),
('UAE','ARE','Asia'),

('USA','USA','North America'),
('Canada','CAN','North America'),
('Mexico','MEX','North America'),

('Brazil','BRA','South America'),
('Argentina','ARG','South America'),

('Australia','AUS','Oceania')
) AS c(country_name, iso, continent_name)
JOIN Continent ct ON ct.name = c.continent_name;



-- ============================================================
-- CITIES
-- 20+ cities linked to countries
-- ============================================================
INSERT INTO City (city_id, name, country_id)
SELECT uuid_generate_v4(), city_name, country_id
FROM (
VALUES
('Lagos','Nigeria'),
('Abuja','Nigeria'),
('Accra','Ghana'),
('Nairobi','Kenya'),
('Cape Town','South Africa'),
('Cairo','Egypt'),

('Paris','France'),
('Berlin','Germany'),
('Rome','Italy'),
('Madrid','Spain'),
('Amsterdam','Netherlands'),

('Beijing','China'),
('Tokyo','Japan'),
('Mumbai','India'),
('Seoul','South Korea'),
('Dubai','UAE'),

('New York','USA'),
('Toronto','Canada'),
('Mexico City','Mexico'),

('Sao Paulo','Brazil'),
('Buenos Aires','Argentina'),
('Sydney','Australia')
) AS c(city_name, country_name)
JOIN Country co ON co.name = c.country_name;



-- ============================================================
-- ADDRESS ROLE
-- Defines purpose of address
-- ============================================================
INSERT INTO AddressRole (address_role_id, name) VALUES
(uuid_generate_v4(), 'Primary Residence'),
(uuid_generate_v4(), 'Billing'),
(uuid_generate_v4(), 'Listing Location'),
(uuid_generate_v4(), 'Business');



-- ============================================================
-- ADDRESS
-- Create reusable addresses (20+)
-- ============================================================
INSERT INTO Address (
    address_id,
    address_line_1,
    city_id,
    state_province,
    postal_code,
    country_id,
    building_name,
    floor_number
)
SELECT
    uuid_generate_v4(),
    'Street ' || generate_series,
    c.city_id,
    'State',
    '1000' || generate_series,
    co.country_id,
    'Building ' || generate_series,
    generate_series::text
FROM City c
JOIN Country co ON co.country_id = c.country_id
LIMIT 25;



-- ============================================================
-- PROFILE ADDRESS
-- Link addresses to existing profiles
-- Each profile gets one primary residence address
-- ============================================================
INSERT INTO ProfileAddress (
    address_id,
    profile_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
    a.address_id,
    p.profile_id,
    ar.address_role_id,
    TRUE,
    CURRENT_DATE
FROM Address a
JOIN profiles p ON TRUE
JOIN AddressRole ar ON ar.name = -- ============================================================
-- Every profile gets ONE Primary Residence
-- ============================================================
INSERT INTO ProfileAddress (
    address_id,
    profile_id,
    address_role_id,
    is_active,
    valid_from
)
SELECT
    a.address_id,
    p.profile_id,
    ar.address_role_id,
    TRUE,
    CURRENT_DATE
FROM profiles p
JOIN Address a ON TRUE
JOIN AddressRole ar ON ar.name = 'Primary Residence'
LIMIT 20;
