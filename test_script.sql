--месяц замены + счетчик без показаний (Июнь 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption, initial_reading, location_address
FROM get_monthly_meter_report(
    (SELECT location_id FROM locations WHERE address = 'г. Минск, ул. Шугаева, д. 33, кв. 33'), 
    '2026-06-01'
);

--стандартный месяц (январь 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption, initial_reading
FROM get_monthly_meter_report(
    (SELECT location_id FROM locations WHERE address = 'г. Фаниполь, ул. Зеленая, д. 83'), 
    '2026-01-01'
);

--установка в середине месяца (январь 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption, initial_reading
FROM get_monthly_meter_report(
    (SELECT location_id FROM locations WHERE address = 'Общедомовое, установка 25-го числа'), 
    '2026-01-01'
);

--демонтаж (февраль 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption, initial_reading
FROM get_monthly_meter_report(
    (SELECT location_id FROM locations WHERE address = 'г. Минск, ул. Интернациональная, д. 54, кв. 77'), 
    '2026-02-01'
);

--после демонтажа (март 2026)
SELECT serial_number, meter_type, reading_start, reading_end, consumption
FROM get_monthly_meter_report(
    (SELECT location_id FROM locations WHERE address = 'г. Минск, ул. Интернациональная, д. 54, кв. 77'), 
    '2026-03-01'
);
