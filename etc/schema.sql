-- schema.sql - a data model for Information Technology and Libraries

-- Eric Lease Morgan <emorgan@nd.edu>
-- October 26, 2019; first cut


-- author, title, date, etc.
CREATE TABLE bibliographics (
	bid        INTEGER PRIMARY KEY,
	identifier TEXT,
	author     TEXT,
	title      TEXT,
	date       TEXT,
	source     TEXT,
	publisher  TEXT,
	language   TEXT,
	doi        TEXT,
	url        TEXT
);
	
-- computed significant words
CREATE TABLE keywords (
	bid     INT,
	keyword TEXT
);

-- extracted names, places, date, etc.
CREATE TABLE entities (
	bid    INT,
	entity TEXT
);

-- make lookups faster
CREATE INDEX identifiers ON bibliographics ( identifier );
