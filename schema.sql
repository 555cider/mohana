-- 
CREATE TABLE type (
    id INTEGER NOT NULL PRIMARY KEY,
    category VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    description TEXT
);

-- 
CREATE SEQUENCE author_id_seq AS INTEGER;
CREATE TABLE author (
  id INTEGER NOT NULL DEFAULT nextval('author_id_seq') PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  url VARCHAR(2048),
  photo_url VARCHAR(2048),
  created_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER SEQUENCE author_id_seq OWNED BY author.id;

-- 
CREATE SEQUENCE address_component_id_seq AS INTEGER;
CREATE TABLE address_component (
    id INTEGER NOT NULL DEFAULT nextval('address_component_id_seq') PRIMARY KEY,
    long_name VARCHAR,
    short_name VARCHAR,
    type_ids INTEGER[]
);
ALTER SEQUENCE address_component_id_seq OWNED BY address_component.id;

-- Attributes describing a place
CREATE TABLE place (
    id VARCHAR primary key, -- Textual identifier that uniquely identifies a place
    address_component_id INTEGER REFERENCES address_component (id) ON UPDATE CASCADE,
    business_status_type_id INTEGER REFERENCES type (id) ON UPDATE CASCADE ON DELETE SET NULL, -- Type for operational status of the business
    compound_code VARCHAR, -- Encoded location reference, derived from latitude and longitude coordinates
    created_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    feature_ids VARCHAR[], -- Array of ids in feature table
    global_code VARCHAR, -- Encoded location reference, derived from latitude and longitude coordinates
    icon VARCHAR(2048), -- URL of a suggested icon
    name VARCHAR, -- Human-readable name for the returned result
    overview TEXT, -- Textual summary of the place
    phone_number VARCHAR, -- Place's phone number in international format
    price_level SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 4), -- Price level of the place (0 to 4)
    rating NUMERIC(1, 1) CHECK (rating >= 1.0 AND rating <= 5.0), -- Place's rating based on aggregated user reviews (1.0 to 5.0)
    type_ids INTEGER[], -- Array of types for place
    url VARCHAR(2048), -- URL of the official Google page for this place
    vicinity VARCHAR, -- Simplified address for the place
    website VARCHAR -- Authoritative website for this place
);

-- 
CREATE TABLE place_feature (
  id VARCHAR NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Location and viewport for the location
CREATE TABLE place_geometry (
    place_id VARCHAR REFERENCES place (id) ON UPDATE CASCADE ON DELETE CASCADE,
    location_lat numeric,
    location_lng numeric,
    viewport_northeast_lat numeric,
    viewport_northeast_lng numeric,
    viewport_southwest_lat numeric,
    viewport_southwest_lng numeric
);

-- The opening hours of a place.
CREATE TABLE place_opening_hour (
    place_id VARCHAR REFERENCES place (id) ON UPDATE CASCADE ON DELETE CASCADE,
    place_type_id INTEGER REFERENCES type (id) ON UPDATE CASCADE ON DELETE SET NULL,
    open_time TIMESTAMP NOT NULL,
    close_time TIMESTAMP
);

-- A review of the place submitted by a user.
CREATE TABLE place_review (
    place_id VARCHAR NOT NULL REFERENCES place (id) ON UPDATE CASCADE ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES author (id) ON UPDATE CASCADE ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5), -- The user's overall rating for this place (0 to 5)
    time INTEGER NOT NULL DEFAULT extract(epoch FROM now()),
    language_type_id INTEGER REFERENCES type (id) ON UPDATE CASCADE ON DELETE SET NULL,
    profile_photo_url VARCHAR(2048),
    text TEXT, -- The user's review
    PRIMARY KEY (place_id, author_id)
);

