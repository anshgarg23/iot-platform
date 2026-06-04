-- ==========================================
-- SCHEMA: IoT Platform
-- ==========================================

-- Devices / Assets
CREATE TABLE IF NOT EXISTS devices (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    location    VARCHAR(100),
    type        VARCHAR(50),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Tags (sensor data points on a device)
CREATE TABLE IF NOT EXISTS tags (
    id          SERIAL PRIMARY KEY,
    device_id   INT REFERENCES devices(id) ON DELETE CASCADE,
    tag_name    VARCHAR(100) NOT NULL,
    unit        VARCHAR(20),
    description TEXT
);

-- Raw telemetry / historian data
CREATE TABLE IF NOT EXISTS telemetry (
    id          BIGSERIAL PRIMARY KEY,
    tag_id      INT REFERENCES tags(id) ON DELETE CASCADE,
    value       DOUBLE PRECISION NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Alarms
CREATE TABLE IF NOT EXISTS alarms (
    id           SERIAL PRIMARY KEY,
    tag_id       INT REFERENCES tags(id) ON DELETE CASCADE,
    severity     VARCHAR(20) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    message      TEXT,
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at  TIMESTAMPTZ,
    is_active    BOOLEAN DEFAULT TRUE
);

-- KPI / OEE results
CREATE TABLE IF NOT EXISTS kpi_results (
    id           SERIAL PRIMARY KEY,
    device_id    INT REFERENCES devices(id) ON DELETE CASCADE,
    kpi_name     VARCHAR(100),
    value        DOUBLE PRECISION,
    calculated_at TIMESTAMPTZ DEFAULT NOW()
);


-- ==========================================
-- SEED DATA
-- ==========================================

-- Insert sample devices
INSERT INTO devices (name, location, type) VALUES
  ('Machine-A', 'Floor 1', 'CNC'),
  ('Machine-B', 'Floor 2', 'Assembly'),
  ('Compressor-1', 'Utility Room', 'Compressor');

-- Insert sample tags
INSERT INTO tags (device_id, tag_name, unit, description) VALUES
  (1, 'temperature',    '°C',  'Spindle temperature'),
  (1, 'vibration',      'mm/s','Vibration level'),
  (2, 'speed',          'RPM', 'Motor speed'),
  (3, 'pressure',       'bar', 'Output pressure'),
  (3, 'power_usage',    'kW',  'Power consumption');

-- Insert sample telemetry
INSERT INTO telemetry (tag_id, value, recorded_at) VALUES
  (1, 72.5,  NOW() - INTERVAL '5 minutes'),
  (1, 74.1,  NOW() - INTERVAL '4 minutes'),
  (2, 0.85,  NOW() - INTERVAL '3 minutes'),
  (3, 1450,  NOW() - INTERVAL '2 minutes'),
  (4, 6.2,   NOW() - INTERVAL '1 minute'),
  (5, 3.8,   NOW());

-- Insert sample alarms
INSERT INTO alarms (tag_id, severity, message) VALUES
  (1, 'HIGH',     'Temperature exceeded 70°C threshold'),
  (4, 'CRITICAL', 'Pressure dropped below safe level');

-- Insert sample KPIs
INSERT INTO kpi_results (device_id, kpi_name, value) VALUES
  (1, 'OEE',          87.5),
  (1, 'Availability', 92.0),
  (2, 'OEE',          78.3);