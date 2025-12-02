
-- ================================================
-- Spiritual Therapy Backend Setup Script (Full DB)
-- ================================================

-- DROP TABLES IF THEY EXIST (clean slate)
DROP TABLE IF EXISTS meeting_attendees, meetings, sessions, user_memberships,
users, guru_assignments, memberships, professions, nakshatras CASCADE;

-- ========== SCHEMA: INTEGER + INDEXES ==========


-- NAKSHATRAS TABLE
CREATE TABLE nakshatras (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- PROFESSIONS TABLE
CREATE TABLE professions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL
);


-- USERS TABLE
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    firebase_uid TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    dob DATE,
    nakshatra_id INTEGER REFERENCES nakshatras(id),
    profession_id INTEGER REFERENCES professions(id),
    address TEXT,
    role TEXT CHECK (role IN ('user', 'guru', 'admin', 'helpdesk')) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- MEMBERSHIPS TABLE
CREATE TABLE memberships (
    id SERIAL PRIMARY KEY,
    tier TEXT CHECK (tier IN ('free', 'silver', 'gold', 'premium')) NOT NULL,
    price DECIMAL NOT NULL,
    max_sessions INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- USER MEMBERSHIPS TABLE
CREATE TABLE user_memberships (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    membership_id INTEGER REFERENCES memberships(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SESSIONS TABLE
CREATE TABLE sessions (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    initiated_type TEXT CHECK (initiated_type IN ('nakshatra', 'profession', 'manual', 'open', 'random')) NOT NULL,
    criteria_value TEXT,
    requested_by BIGINT REFERENCES users(id),
    guru_id BIGINT REFERENCES users(id),
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MEETINGS TABLE
CREATE TABLE meetings (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT REFERENCES sessions(id),
    guru_id BIGINT REFERENCES users(id),
    title TEXT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    max_attendees INT NOT NULL,
    agora_channel_id TEXT NOT NULL,
    agora_token TEXT NOT NULL,
    is_live BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MEETING ATTENDEES TABLE
CREATE TABLE meeting_attendees (
    id BIGSERIAL PRIMARY KEY,
    meeting_id BIGINT REFERENCES meetings(id),
    user_id BIGINT REFERENCES users(id),
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    auto_added BOOLEAN DEFAULT FALSE
);

-- GURU ASSIGNMENTS TABLE
CREATE TABLE guru_assignments (
    id BIGSERIAL PRIMARY KEY,
    guru_id BIGINT REFERENCES users(id),
    user_id BIGINT REFERENCES users(id),
    method TEXT CHECK (method IN ('nakshatra', 'profession', 'manual')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========== INDEXES & CONSTRAINTS ==========
CREATE UNIQUE INDEX user_phone_key ON users(phone);
CREATE UNIQUE INDEX user_email_key ON users(email);
CREATE UNIQUE INDEX meeting_agora_channel_id_key ON meetings(agora_channel_id);
CREATE UNIQUE INDEX meeting_attendees_meeting_user_key ON meeting_attendees(meeting_id, user_id);

CREATE INDEX users_phone_idx ON users(phone);
CREATE INDEX users_email_idx ON users(email);
CREATE INDEX sessions_status_idx ON sessions(status);
CREATE INDEX sessions_requested_by_idx ON sessions(requested_by);
CREATE INDEX meetings_start_time_idx ON meetings(start_time);
CREATE INDEX meetings_session_id_idx ON meetings(session_id);
CREATE INDEX meetings_guru_id_idx ON meetings(guru_id);
CREATE INDEX meetings_is_live_idx ON meetings(is_live);
CREATE INDEX meetings_created_at_idx ON meetings(created_at);
CREATE INDEX meeting_attendees_meeting_idx ON meeting_attendees(meeting_id);
CREATE INDEX meeting_attendees_user_idx ON meeting_attendees(user_id);

ALTER TABLE sessions 
  ADD CONSTRAINT fk_sessions_requested_by FOREIGN KEY (requested_by) 
  REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE meetings 
  ADD CONSTRAINT fk_meetings_session_id FOREIGN KEY (session_id) 
  REFERENCES sessions(id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE meeting_attendees 
  ADD CONSTRAINT fk_meeting_attendees_user FOREIGN KEY (user_id) 
  REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- ========== CONFIG DATA (NAKSHATRAS & MEMBERSHIPS) ==========
INSERT INTO nakshatras (id, name) VALUES
(1, 'Ashwini'), (2, 'Bharani'), (3, 'Krittika'), (4, 'Rohini'), (5, 'Mrigashira'),
(6, 'Ardra'), (7, 'Punarvasu'), (8, 'Pushya'), (9, 'Ashlesha'), (10, 'Magha'),
(11, 'Purva Phalguni'), (12, 'Uttara Phalguni'), (13, 'Hasta'), (14, 'Chitra'),
(15, 'Swati'), (16, 'Vishakha'), (17, 'Anuradha'), (18, 'Jyeshtha'), (19, 'Mula'),
(20, 'Purva Ashadha'), (21, 'Uttara Ashadha'), (22, 'Shravana'), (23, 'Dhanishta'),
(24, 'Shatabhisha'), (25, 'Purva Bhadrapada'), (26, 'Uttara Bhadrapada'), (27, 'Revati');

INSERT INTO memberships (id, tier, price, max_sessions, created_at) VALUES
(1, 'free', 0.0, 2, CURRENT_TIMESTAMP),
(2, 'silver', 199.99, 4, CURRENT_TIMESTAMP),
(3, 'gold', 499.99, 10, CURRENT_TIMESTAMP),
(4, 'premium', 999.99, 999, CURRENT_TIMESTAMP);

-- ========== PROFESSIONS ==========
INSERT INTO professions (id, title) VALUES
(1, 'Doctor'), (2, 'Engineer'), (3, 'Artist'), (4, 'Teacher'), (5, 'Lawyer'),
(6, 'Therapist'), (7, 'Counselor'), (8, 'Software Developer'),
(9, 'Entrepreneur'), (10, 'Spiritual Seeker');

-- ========== DUMMY USERS ==========
INSERT INTO users (id, firebase_uid, first_name, last_name, email, phone, role, nakshatra_id, profession_id) VALUES
(101, 'firebase_test_guru', 'Test', 'Guru', 'guru@example.com', '9990000001', 'guru', 1, 1),
(102, 'firebase_test_user1', 'Test', 'User1', 'user1@example.com', '9990000002', 'user', 1, 2),
(103, 'firebase_test_user2', 'Test', 'User2', 'user2@example.com', '9990000003', 'user', 1, 3),
(104, 'firebase_test_user3', 'Test', 'User3', 'user3@example.com', '9990000004', 'user', 1, 4);

-- ========== DUMMY SESSION ==========
INSERT INTO sessions (id, title, description, initiated_type, criteria_value, requested_by, guru_id, status, created_at) VALUES
(201, 'test_session_1', 'Session for Ashwini Nakshatra', 'nakshatra', 'Ashwini', 102, 101, 'approved', CURRENT_TIMESTAMP);

-- ========== DUMMY MEETING ==========
INSERT INTO meetings (id, session_id, guru_id, title, start_time, end_time, max_attendees, agora_channel_id, agora_token, is_live, created_at) VALUES
(301, 201, 101, 'test_meeting_1', CURRENT_DATE + TIME '10:00', CURRENT_DATE + TIME '11:00', 50, 'test_meeting_1', 'dummy_agora_token_123', true, CURRENT_TIMESTAMP);

-- ========== DUMMY ATTENDEES ==========
INSERT INTO meeting_attendees (id, meeting_id, user_id, auto_added) VALUES
(401, 301, 102, true), (402, 301, 103, true), (403, 301, 104, true);
