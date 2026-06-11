CREATE TYPE meter_type AS ENUM ('cold_water', 'hot_water', 'electricity', 'gas'); 

CREATE TABLE locations (
    location_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address TEXT NOT NULL,
    location_type TEXT NOT NULL CHECK (location_type IN ('apartment', 'house', 'common_area')),  
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE meters (
    meter_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    serial_number VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE meter_installations (
    installation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    meter_id BIGINT NOT NULL REFERENCES meters(meter_id) ON DELETE CASCADE,
    location_id BIGINT NOT NULL REFERENCES locations(location_id) ON DELETE CASCADE,
    meter_type meter_type NOT NULL,
    installation_date DATE NOT NULL,
    deinstallation_date DATE, 
    initial_reading NUMERIC(12,4) NOT NULL,
    CONSTRAINT chk_dates CHECK (deinstallation_date IS NULL OR deinstallation_date > installation_date)
);

-- быстрый поиск установок по месту и датам
CREATE INDEX idx_inst_location_dates ON meter_installations(location_id, installation_date, deinstallation_date);


CREATE TABLE readings (
    installation_id BIGINT NOT NULL REFERENCES meter_installations(installation_id) ON DELETE CASCADE,
    reading_date DATE NOT NULL,
    value NUMERIC(12,4) NOT NULL,
    PRIMARY KEY (installation_id, reading_date)
) PARTITION BY RANGE (reading_date);


-- партиции на 2025-2026 годы (в продакшене создаются автоматически)
CREATE TABLE readings_2025_12 PARTITION OF readings FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');
CREATE TABLE readings_2026_01 PARTITION OF readings FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE readings_2026_02 PARTITION OF readings FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE readings_2026_03 PARTITION OF readings FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE readings_2026_04 PARTITION OF readings FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE readings_2026_05 PARTITION OF readings FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE readings_2026_06 PARTITION OF readings FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE readings_default PARTITION OF readings DEFAULT;



--функция для определения показаний приборов учета за отчетный период по месту
CREATE OR REPLACE FUNCTION get_monthly_meter_report(
    p_location_id BIGINT,
    p_report_month DATE
) RETURNS TABLE (
    serial_number VARCHAR,
    meter_type meter_type,
    reading_start NUMERIC,
    reading_end NUMERIC,
    consumption NUMERIC,
    initial_reading NUMERIC,
    location_address TEXT
) LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_start DATE := DATE_TRUNC('month', p_report_month)::DATE;
    v_end   DATE := (v_start + INTERVAL '1 month - 1 day')::DATE;
BEGIN
    RETURN QUERY
    SELECT 
        m.serial_number,
        mi.meter_type,
        r_start.val,
        r_end.val,
        CASE 
            WHEN r_start.val IS NOT NULL AND r_end.val IS NOT NULL 
            THEN ROUND(r_end.val - r_start.val, 4)
            ELSE NULL 
        END,
        mi.initial_reading,
        l.address
    FROM meter_installations mi
    JOIN meters m ON m.meter_id = mi.meter_id          
    JOIN locations l ON l.location_id = mi.location_id  
    LEFT JOIN LATERAL (
        SELECT value AS val FROM readings
        WHERE installation_id = mi.installation_id      
          AND reading_date BETWEEN v_start AND v_end
        ORDER BY reading_date ASC LIMIT 1
    ) r_start ON true
    LEFT JOIN LATERAL (
        SELECT value AS val FROM readings
        WHERE installation_id = mi.installation_id      
          AND reading_date BETWEEN v_start AND v_end
        ORDER BY reading_date DESC LIMIT 1
    ) r_end ON true
    WHERE mi.location_id = p_location_id
      AND mi.installation_date <= v_end
      AND (mi.deinstallation_date IS NULL OR mi.deinstallation_date >= v_start)
    ORDER BY mi.installation_date ASC, mi.installation_id ASC; 
END;
$$;
