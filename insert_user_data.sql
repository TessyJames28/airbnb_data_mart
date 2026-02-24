i-- ======================================================
-- INSERT SAMPLE DATA FOR USERS, PROFILES, ROLES, SOCIALS
-- ======================================================

-- 1️⃣ ROLES: Only two roles: guest and host
INSERT INTO Role (role_id, role_type)
VALUES
  (uuid_generate_v4(), 'guest'),
  (uuid_generate_v4(), 'host');

-- Fetch the role_ids for later use
-- (In practice, you can select them into variables in psql or just copy the UUIDs)

-- 2️⃣ USERS
INSERT INTO Users (user_id, email, phone_number, password, is_active)
VALUES
  (uuid_generate_v4(), 'alice@example.com', '+12345678901', 'password123', TRUE),
  (uuid_generate_v4(), 'bob@example.com', '+12345678902', 'password123', TRUE),
  (uuid_generate_v4(), 'carol@example.com', '+12345678903', 'password123', TRUE),
  (uuid_generate_v4(), 'dave@example.com', '+12345678904', 'password123', TRUE),
  (uuid_generate_v4(), 'eve@example.com', '+12345678905', 'password123', TRUE),
  (uuid_generate_v4(), 'frank@example.com', '+12345678906', 'password123', TRUE),
  (uuid_generate_v4(), 'grace@example.com', '+12345678907', 'password123', TRUE),
  (uuid_generate_v4(), 'heidi@example.com', '+12345678908', 'password123', TRUE),
  (uuid_generate_v4(), 'ivan@example.com', '+12345678909', 'password123', TRUE),
  (uuid_generate_v4(), 'judy@example.com', '+12345678910', 'password123', TRUE),
  (uuid_generate_v4(), 'kim@example.com', '+12345678911', 'password123', TRUE),
  (uuid_generate_v4(), 'leo@example.com', '+12345678912', 'password123', TRUE),
  (uuid_generate_v4(), 'mia@example.com', '+12345678913', 'password123', TRUE),
  (uuid_generate_v4(), 'nick@example.com', '+12345678914', 'password123', TRUE),
  (uuid_generate_v4(), 'olivia@example.com', '+12345678915', 'password123', TRUE),
  (uuid_generate_v4(), 'peggy@example.com', '+12345678916', 'password123', TRUE),
  (uuid_generate_v4(), 'quinn@example.com', '+12345678917', 'password123', TRUE),
  (uuid_generate_v4(), 'rachel@example.com', '+12345678918', 'password123', TRUE),
  (uuid_generate_v4(), 'steve@example.com', '+12345678919', 'password123', TRUE),
  (uuid_generate_v4(), 'trudy@example.com', '+12345678920', 'password123', TRUE);

-- 3️⃣ PROFILES: One per user
INSERT INTO Profile (profile_id, user_id, first_name, last_name, image_url)
SELECT uuid_generate_v4(), u.user_id, 
       split_part(u.email,'@',1)::varchar, 
       'Lastname', 
       'https://example.com/avatar/' || split_part(u.email,'@',1)
FROM Users u;

-- 4️⃣ USER_ROLES: Assign roles
-- Assign guest role to all, host role to half
INSERT INTO UserRoles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u
JOIN Roles r ON r.role_type = 'guest';

INSERT INTO UserRole (user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u
JOIN Role r ON r.role_type = 'host'
WHERE u.email IN ('alice@example.com','bob@example.com','carol@example.com','dave@example.com',
                  'eve@example.com','frank@example.com','grace@example.com','heidi@example.com',
                  'ivan@example.com','judy@example.com'); -- first 10 users as hosts

-- 5️⃣ SOCIALS
INSERT INTO Social (social_id, social_platform)
VALUES
  (uuid_generate_v4(), 'Facebook'),
  (uuid_generate_v4(), 'Instagram'),
  (uuid_generate_v4(), 'LinkedIn'),
  (uuid_generate_v4(), 'Twitter'),
  (uuid_generate_v4(), 'TikTok');

-- 6️⃣ PROFILE_SOCIALS
-- Each profile gets all socials
INSERT INTO ProfileSocial (profile_id, social_id, social_handle, url, is_primary)
SELECT p.profile_id, s.social_id,
       CONCAT(split_part(u.email,'@',1),'_',s.social_platform),
       'https://' || s.social_platform || '.com/' || split_part(u.email,'@',1),
       TRUE
FROM Profile p
JOIN Users u ON u.user_id = p.user_id
CROSS JOIN Social s;

-- 7️⃣ LANGUAGES: Add 20 languages
INSERT INTO Language (language_id, language_name, iso_code)
VALUES
  (uuid_generate_v4(), 'English', 'EN'),
  (uuid_generate_v4(), 'French', 'FR'),
  (uuid_generate_v4(), 'Spanish', 'ES'),
  (uuid_generate_v4(), 'German', 'DE'),
  (uuid_generate_v4(), 'Italian', 'IT'),
  (uuid_generate_v4(), 'Portuguese', 'PT'),
  (uuid_generate_v4(), 'Russian', 'RU'),
  (uuid_generate_v4(), 'Mandarin', 'ZH'),
  (uuid_generate_v4(), 'Japanese', 'JA'),
  (uuid_generate_v4(), 'Korean', 'KO'),
  (uuid_generate_v4(), 'Arabic', 'AR'),
  (uuid_generate_v4(), 'Hindi', 'HI'),
  (uuid_generate_v4(), 'Bengali', 'BN'),
  (uuid_generate_v4(), 'Turkish', 'TR'),
  (uuid_generate_v4(), 'Vietnamese', 'VI'),
  (uuid_generate_v4(), 'Polish', 'PL'),
  (uuid_generate_v4(), 'Dutch', 'NL'),
  (uuid_generate_v4(), 'Swedish', 'SV'),
  (uuid_generate_v4(), 'Greek', 'EL'),
  (uuid_generate_v4(), 'Hebrew', 'HE');

-- 8️⃣ HOST_LANGUAGES: Only assign to hosts
INSERT INTO HostLanguage (profile_id, language_id, proficiency_level)
SELECT p.profile_id, l.language_id,
       CASE
           WHEN l.language_name IN ('English','French','Spanish') THEN 'native'
           WHEN l.language_name IN ('German','Italian','Portuguese') THEN 'fluent'
           ELSE 'beginner'
       END
FROM Profile p
JOIN UserRole ur ON ur.user_id = p.user_id
JOIN Role r ON r.role_id = ur.role_id
JOIN Language l ON TRUE
WHERE r.role_type = 'host';
