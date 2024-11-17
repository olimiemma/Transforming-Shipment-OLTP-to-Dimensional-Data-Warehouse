-- Add more dates (for January 2024)
INSERT INTO DIM_Date (DateKey, FullDate, Year, Quarter, Month, MonthName, DayOfWeek, DayName, IsWeekend, FiscalYear)
VALUES 
(20240103, '2024-01-03', 2024, 1, 1, 'January', 3, 'Wednesday', 'N', 2024),
(20240104, '2024-01-04', 2024, 1, 1, 'January', 4, 'Thursday', 'N', 2024),
(20240105, '2024-01-05', 2024, 1, 1, 'January', 5, 'Friday', 'N', 2024),
(20240106, '2024-01-06', 2024, 1, 1, 'January', 6, 'Saturday', 'Y', 2024),
(20240107, '2024-01-07', 2024, 1, 1, 'January', 7, 'Sunday', 'Y', 2024),
(20240108, '2024-01-08', 2024, 1, 1, 'January', 1, 'Monday', 'N', 2024);

-- Add more carriers
INSERT INTO DIM_Carrier (CarrierID, CarrierName, ValidFrom, ValidTo, IsCurrent)
VALUES 
('CAR003', 'CMA CGM', '2024-01-01', '9999-12-31', 'Y'),
('CAR004', 'COSCO', '2024-01-01', '9999-12-31', 'Y'),
('CAR005', 'Hapag-Lloyd', '2024-01-01', '9999-12-31', 'Y');

-- Add more containers
INSERT INTO DIM_Container (ContainerID, ContainerType, ContainerSize, ValidFrom, ValidTo, IsCurrent)
VALUES 
('CONT003', 'Dry', '20ft', '2024-01-01', '9999-12-31', 'Y'),
('CONT004', 'Reefer', '40ft', '2024-01-01', '9999-12-31', 'Y'),
('CONT005', 'Flat Rack', '40ft', '2024-01-01', '9999-12-31', 'Y');

-- Add more ports
INSERT INTO DIM_Port (PortID, PortName, Country, Region, ValidFrom, ValidTo, IsCurrent)
VALUES 
('PORT003', 'Singapore', 'Singapore', 'Asia', '2024-01-01', '9999-12-31', 'Y'),
('PORT004', 'Los Angeles', 'USA', 'North America', '2024-01-01', '9999-12-31', 'Y'),
('PORT005', 'Dubai', 'UAE', 'Middle East', '2024-01-01', '9999-12-31', 'Y');

-- Add more event types
INSERT INTO DIM_EventType (EventTypeID, EventTypeName, EventCategory, ValidFrom, ValidTo, IsCurrent)
VALUES 
('EVT003', 'Vessel Arrival', 'Vessel', '2024-01-01', '9999-12-31', 'Y'),
('EVT004', 'Customs Clearance', 'Documentation', '2024-01-01', '9999-12-31', 'Y'),
('EVT005', 'Gate Out', 'Terminal', '2024-01-01', '9999-12-31', 'Y');

-- Add more shipments with varying delays and costs
INSERT INTO FACT_Shipment (
    ShipmentID, CarrierKey, ContainerKey, ShipmentTypeKey,
    OriginPortKey, DestinationPortKey,
    ScheduledStartDateKey, ScheduledEndDateKey,
    ActualStartDateKey, ActualEndDateKey,
    TotalDistance, TotalCost
)
SELECT 'SHIP002', 
    (SELECT CarrierKey FROM DIM_Carrier WHERE CarrierID = 'CAR002'),
    (SELECT ContainerKey FROM DIM_Container WHERE ContainerID = 'CONT002'),
    (SELECT ShipmentTypeKey FROM DIM_ShipmentType WHERE ShipmentTypeID = 'ST001'),
    (SELECT PortKey FROM DIM_Port WHERE PortID = 'PORT001'),
    (SELECT PortKey FROM DIM_Port WHERE PortID = 'PORT003'),
    20240101, 20240103, 20240101, 20240104,
    2000.00, 3000.00;

INSERT INTO FACT_Shipment (
    ShipmentID, CarrierKey, ContainerKey, ShipmentTypeKey,
    OriginPortKey, DestinationPortKey,
    ScheduledStartDateKey, ScheduledEndDateKey,
    ActualStartDateKey, ActualEndDateKey,
    TotalDistance, TotalCost
)
SELECT 'SHIP003',
    (SELECT CarrierKey FROM DIM_Carrier WHERE CarrierID = 'CAR003'),
    (SELECT ContainerKey FROM DIM_Container WHERE ContainerID = 'CONT003'),
    (SELECT ShipmentTypeKey FROM DIM_ShipmentType WHERE ShipmentTypeID = 'ST002'),
    (SELECT PortKey FROM DIM_Port WHERE PortID = 'PORT002'),
    (SELECT PortKey FROM DIM_Port WHERE PortID = 'PORT004'),
    20240102, 20240105, 20240102, 20240106,
    3500.00, 4500.00;

INSERT INTO FACT_Shipment (
    ShipmentID, CarrierKey, ContainerKey, ShipmentTypeKey,
    OriginPortKey, DestinationPortKey,
    ScheduledStartDateKey, ScheduledEndDateKey,
    ActualStartDateKey, ActualEndDateKey,
    TotalDistance, TotalCost
)
SELECT 'SHIP004',
    (SELECT CarrierKey FROM DIM_Carrier WHERE CarrierID = 'CAR004'),
    (SELECT ContainerKey FROM DIM_Container WHERE ContainerID = 'CONT004'),
    (SELECT ShipmentTypeKey FROM DIM_ShipmentType WHERE ShipmentTypeID = 'ST001'),
    (SELECT PortKey FROM DIM_Port WHERE PortID = 'PORT003'),
    (SELECT PortKey FROM DIM_Port WHERE PortID = 'PORT005'),
    20240103, 20240105, 20240103, 20240107,
    1800.00, 2800.00;

-- Add corresponding events for new shipments
INSERT INTO FACT_ShipmentEvent (ShipmentKey, EventTypeKey, EventDateKey, PortKey, Duration)
SELECT 
    s.ShipmentKey,
    (SELECT EventTypeKey FROM DIM_EventType WHERE EventTypeID = 'EVT001'),
    s.ActualStartDateKey,
    s.OriginPortKey,
    90
FROM FACT_Shipment s
WHERE s.ShipmentID IN ('SHIP002', 'SHIP003', 'SHIP004');

INSERT INTO FACT_ShipmentEvent (ShipmentKey, EventTypeKey, EventDateKey, PortKey, Duration)
SELECT 
    s.ShipmentKey,
    (SELECT EventTypeKey FROM DIM_EventType WHERE EventTypeID = 'EVT002'),
    s.ActualStartDateKey,
    s.OriginPortKey,
    150
FROM FACT_Shipment s
WHERE s.ShipmentID IN ('SHIP002', 'SHIP003', 'SHIP004');

INSERT INTO FACT_ShipmentEvent (ShipmentKey, EventTypeKey, EventDateKey, PortKey, Duration)
SELECT 
    s.ShipmentKey,
    (SELECT EventTypeKey FROM DIM_EventType WHERE EventTypeID = 'EVT003'),
    s.ActualEndDateKey,
    s.DestinationPortKey,
    120
FROM FACT_Shipment s
WHERE s.ShipmentID IN ('SHIP002', 'SHIP003', 'SHIP004');





--Had some duplicates
WITH DuplicateCTE AS (
    SELECT EventKey,
           ROW_NUMBER() OVER (
               PARTITION BY ShipmentKey, EventTypeKey, EventDateKey, PortKey
               ORDER BY EventKey
           ) as RowNum
    FROM FACT_ShipmentEvent
)
SELECT * FROM DuplicateCTE WHERE RowNum > 1;

-- deleted them
DELETE FROM FACT_ShipmentEvent
WHERE EventKey IN (
    SELECT EventKey
    FROM (
        SELECT EventKey,
           ROW_NUMBER() OVER (
               PARTITION BY ShipmentKey, EventTypeKey, EventDateKey, PortKey
               ORDER BY EventKey
           ) as RowNum
        FROM FACT_ShipmentEvent
    ) dups
    WHERE RowNum > 1
);



-- Verify no duplicates exist
SELECT ShipmentKey, EventTypeKey, EventDateKey, PortKey, COUNT(*)
FROM FACT_ShipmentEvent
GROUP BY ShipmentKey, EventTypeKey, EventDateKey, PortKey
HAVING COUNT(*) > 1;