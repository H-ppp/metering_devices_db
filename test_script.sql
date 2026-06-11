--месяц замены + счетчик без показаний (Июнь 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption, initial_reading, location_address
FROM get_monthly_meter_report(
    (SELECT location_id FROM locations WHERE address = 'г. Минск, ул. Шугаева, д. 33, кв. 33'), 
    '2026-06-01'
);

--стандартный месяц (январь 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption, initial_reading
FROM get_monthly_meter_report(
    , 
    '2026-01-01'
);
