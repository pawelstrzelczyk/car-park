PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;

DROP TABLE IF EXISTS gas_alerts;
DROP TABLE IF EXISTS entries;

CREATE TABLE gas_alerts(
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE entries(
    id INTEGER PRIMARY KEY,
    license_plate_number VARCHAR(7) NOT NULL,
    entry_timestamp TIMESTAMP,
    exit_timestamp TIMESTAMP,
    paid BOOLEAN DEFAULT 0,
    fee REAL DEFAULT 0
);