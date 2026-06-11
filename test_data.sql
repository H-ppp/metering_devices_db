DO $$
DECLARE
    -- сценарий 1: квартира (замена, счетчик без показаний)
    v_loc_apt BIGINT;
    v_m_old_hw BIGINT; v_i_old_hw BIGINT; 
    v_m_new_cw BIGINT; v_i_new_cw BIGINT; 
    v_m_gas BIGINT;    v_i_gas BIGINT;    

    -- сценарий 2: частный дом (стандартный сценарий, стабильные показания)
    v_loc_house BIGINT;
    v_m_elec BIGINT;   v_i_elec BIGINT;   

    -- сценарий 3: общедомовое (установка в середине месяца)
    v_loc_common BIGINT;
    v_m_cw_common BIGINT; v_i_cw_common BIGINT;

    -- сценарий 4: квартира (счетчик демонтирован)
    v_loc_old BIGINT;
    v_m_old_cw BIGINT; v_i_old_cw BIGINT;
BEGIN

    INSERT INTO locations (address, location_type) VALUES ('г. Минск, ул. Шугаева, д. 33, кв. 33', 'apartment') RETURNING location_id INTO v_loc_apt;
    
    INSERT INTO meters (serial_number) VALUES ('M-OLD-HW') RETURNING meter_id INTO v_m_old_hw;
    INSERT INTO meter_installations (meter_id, location_id, meter_type, installation_date, deinstallation_date, initial_reading)
    VALUES (v_m_old_hw, v_loc_apt, 'hot_water', '2025-01-01', '2026-06-15', 100.00) RETURNING installation_id INTO v_i_old_hw;

    INSERT INTO meters (serial_number) VALUES ('M-NEW-CW') RETURNING meter_id INTO v_m_new_cw;
    INSERT INTO meter_installations (meter_id, location_id, meter_type, installation_date, deinstallation_date, initial_reading)
    VALUES (v_m_new_cw, v_loc_apt, 'cold_water', '2026-06-15', NULL, 0.00) RETURNING installation_id INTO v_i_new_cw;

    INSERT INTO meters (serial_number) VALUES ('M-GAS-SILENT') RETURNING meter_id INTO v_m_gas;
    INSERT INTO meter_installations (meter_id, location_id, meter_type, installation_date, deinstallation_date, initial_reading)
    VALUES (v_m_gas, v_loc_apt, 'gas', '2026-01-01', NULL, 500.00) RETURNING installation_id INTO v_i_gas;

    -- показания сценарий 1
    INSERT INTO readings (installation_id, reading_date, value) VALUES
    (v_i_old_hw, '2026-06-01', 150.00), (v_i_old_hw, '2026-06-15', 160.00), -- старый счетчик
    (v_i_new_cw, '2026-06-15', 0.00), (v_i_new_cw, '2026-06-30', 15.50);  -- новый счетчик
    -- для газа показаний в июне НЕТ

    
    -- сценарий 2
    INSERT INTO locations (address, location_type) VALUES ('г. Фаниполь, ул. Зеленая, д. 83', 'house') RETURNING location_id INTO v_loc_house;
    INSERT INTO meters (serial_number) VALUES ('M-ELEC-HOUSE') RETURNING meter_id INTO v_m_elec;
    INSERT INTO meter_installations (meter_id, location_id, meter_type, installation_date, deinstallation_date, initial_reading)
    VALUES (v_m_elec, v_loc_house, 'electricity', '2026-01-01', NULL, 1000.00) RETURNING installation_id INTO v_i_elec;

    INSERT INTO readings (installation_id, reading_date, value) VALUES
    (v_i_elec, '2026-01-01', 1000.00),
    (v_i_elec, '2026-01-15', 1050.00),
    (v_i_elec, '2026-01-31', 1100.00);

    -- сценарий 3 
    INSERT INTO locations (address, location_type) VALUES ('Общедомовое, установка 25-го числа', 'common_area') RETURNING location_id INTO v_loc_common;
    INSERT INTO meters (serial_number) VALUES ('M-CW-COMMON') RETURNING meter_id INTO v_m_cw_common;
    INSERT INTO meter_installations (meter_id, location_id, meter_type, installation_date, deinstallation_date, initial_reading)
    VALUES (v_m_cw_common, v_loc_common, 'cold_water', '2026-01-25', NULL, 0.00) RETURNING installation_id INTO v_i_cw_common;

    INSERT INTO readings (installation_id, reading_date, value) VALUES
    (v_i_cw_common, '2026-01-25', 0.00),
    (v_i_cw_common, '2026-01-31', 10.00);

    
   -- сценарий 4
    INSERT INTO locations (address, location_type) VALUES ('г. Минск, ул. Интернациональная, д. 54, кв. 77', 'apartment') RETURNING location_id INTO v_loc_old;
    INSERT INTO meters (serial_number) VALUES ('M-OLD-DEINST') RETURNING meter_id INTO v_m_old_cw;
    INSERT INTO meter_installations (meter_id, location_id, meter_type, installation_date, deinstallation_date, initial_reading)
    VALUES (v_m_old_cw, v_loc_old, 'cold_water', '2025-06-01', '2026-02-10', 200.00) RETURNING installation_id INTO v_i_old_cw;

    INSERT INTO readings (installation_id, reading_date, value) VALUES
    (v_i_old_cw, '2026-02-01', 250.00),
    (v_i_old_cw, '2026-02-10', 255.00); -- последнее показание
END $$;