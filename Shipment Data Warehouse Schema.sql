-- Dimension tables
CREATE TABLE DIM_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    IsWeekend CHAR(1) NOT NULL,
    FiscalYear INT NOT NULL
);

CREATE TABLE DIM_Carrier (
    CarrierKey SERIAL PRIMARY KEY,  -- SERIAL 
    CarrierID VARCHAR(20) NOT NULL,  -- business key
    CarrierName VARCHAR(100) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    IsCurrent CHAR(1) NOT NULL
);

CREATE TABLE DIM_Container (
    ContainerKey SERIAL PRIMARY KEY,  -- SERIAL 
    ContainerID VARCHAR(20) NOT NULL,  -- business key
    ContainerType VARCHAR(50) NOT NULL,
    ContainerSize VARCHAR(20) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    IsCurrent CHAR(1) NOT NULL
);

CREATE TABLE DIM_Port (
    PortKey SERIAL PRIMARY KEY,  -- SERIAL 
    PortID VARCHAR(20) NOT NULL,  -- business key
    PortName VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    IsCurrent CHAR(1) NOT NULL
);

CREATE TABLE DIM_ShipmentType (
    ShipmentTypeKey SERIAL PRIMARY KEY,  -- SERIAL 
    ShipmentTypeID VARCHAR(20) NOT NULL,  -- business key
    ShipmentTypeName VARCHAR(50) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    IsCurrent CHAR(1) NOT NULL
);

CREATE TABLE DIM_EventType (
    EventTypeKey SERIAL PRIMARY KEY,  -- SERIAL 
    EventTypeID VARCHAR(20) NOT NULL,  -- business key
    EventTypeName VARCHAR(50) NOT NULL,
    EventCategory VARCHAR(50) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    IsCurrent CHAR(1) NOT NULL
);



-- Fact tables
CREATE TABLE FACT_Shipment (
    ShipmentKey SERIAL PRIMARY KEY,  -- SERIAL 
    ShipmentID VARCHAR(20) NOT NULL,  -- business key
    CarrierKey INT NOT NULL,
    ContainerKey INT NOT NULL,
    ShipmentTypeKey INT NOT NULL,
    OriginPortKey INT NOT NULL,
    DestinationPortKey INT NOT NULL,
    ScheduledStartDateKey INT NOT NULL,
    ScheduledEndDateKey INT NOT NULL,
    ActualStartDateKey INT NOT NULL,
    ActualEndDateKey INT NOT NULL,
    TotalDistance DECIMAL(10,2),
    TotalCost DECIMAL(12,2),
    FOREIGN KEY (CarrierKey) REFERENCES DIM_Carrier(CarrierKey),
    FOREIGN KEY (ContainerKey) REFERENCES DIM_Container(ContainerKey),
    FOREIGN KEY (ShipmentTypeKey) REFERENCES DIM_ShipmentType(ShipmentTypeKey),
    FOREIGN KEY (OriginPortKey) REFERENCES DIM_Port(PortKey),
    FOREIGN KEY (DestinationPortKey) REFERENCES DIM_Port(PortKey),
    FOREIGN KEY (ScheduledStartDateKey) REFERENCES DIM_Date(DateKey),
    FOREIGN KEY (ScheduledEndDateKey) REFERENCES DIM_Date(DateKey),
    FOREIGN KEY (ActualStartDateKey) REFERENCES DIM_Date(DateKey),
    FOREIGN KEY (ActualEndDateKey) REFERENCES DIM_Date(DateKey)
);

CREATE TABLE FACT_ShipmentEvent (
    EventKey SERIAL PRIMARY KEY,  -- SERIAL 
    ShipmentKey INT NOT NULL,
    EventTypeKey INT NOT NULL,
    EventDateKey INT NOT NULL,
    PortKey INT NOT NULL,
    Duration INT,  -- in minutes
    FOREIGN KEY (ShipmentKey) REFERENCES FACT_Shipment(ShipmentKey),
    FOREIGN KEY (EventTypeKey) REFERENCES DIM_EventType(EventTypeKey),
    FOREIGN KEY (EventDateKey) REFERENCES DIM_Date(DateKey),
    FOREIGN KEY (PortKey) REFERENCES DIM_Port(PortKey)
);

-- Sample data loading
-- First loading dimension tables
INSERT INTO DIM_Date (DateKey, FullDate, Year, Quarter, Month, MonthName, DayOfWeek, DayName, IsWeekend, FiscalYear)
VALUES 
(20240101, '2024-01-01', 2024, 1, 1, 'January', 1, 'Monday', 'N', 2024),
(20240102, '2024-01-02', 2024, 1, 1, 'January', 2, 'Tuesday', 'N', 2024);

Select * from DIM_Date

INSERT INTO DIM_Carrier (CarrierID, CarrierName, ValidFrom, ValidTo, IsCurrent)
VALUES 
('CAR001', 'Maersk Line', '2024-01-01', '9999-12-31', 'Y'),
('CAR002', 'MSC', '2024-01-01', '9999-12-31', 'Y');

Select * from DIM_Carrier

INSERT INTO DIM_Container (ContainerID, ContainerType, ContainerSize, ValidFrom, ValidTo, IsCurrent)
VALUES 
('CONT001', 'Dry', '40ft', '2024-01-01', '9999-12-31', 'Y'),
('CONT002', 'Reefer', '20ft', '2024-01-01', '9999-12-31', 'Y');

Select * from DIM_Container

INSERT INTO DIM_Port (PortID, PortName, Country, Region, ValidFrom, ValidTo, IsCurrent)
VALUES 
('PORT001', 'Shanghai', 'China', 'Asia', '2024-01-01', '9999-12-31', 'Y'),
('PORT002', 'Rotterdam', 'Netherlands', 'Europe', '2024-01-01', '9999-12-31', 'Y');

Select * from DIM_Port

INSERT INTO DIM_ShipmentType (ShipmentTypeID, ShipmentTypeName, ValidFrom, ValidTo, IsCurrent)
VALUES 
('ST001', 'FCL', '2024-01-01', '9999-12-31', 'Y'),--FCL (Full Container Load)
('ST002', 'LCL', '2024-01-01', '9999-12-31', 'Y');--LCL (Less than Container Load)

Select * from DIM_ShipmentType

INSERT INTO DIM_EventType (EventTypeID, EventTypeName, EventCategory, ValidFrom, ValidTo, IsCurrent)
VALUES 
('EVT001', 'Gate In', 'Terminal', '2024-01-01', '9999-12-31', 'Y'),
('EVT002', 'Vessel Departure', 'Vessel', '2024-01-01', '9999-12-31', 'Y');

Select * from DIM_EventType

-- Then loading fact tables
INSERT INTO FACT_Shipment (
    ShipmentID, CarrierKey, ContainerKey, ShipmentTypeKey, 
    OriginPortKey, DestinationPortKey,
    ScheduledStartDateKey, ScheduledEndDateKey, 
    ActualStartDateKey, ActualEndDateKey,
    TotalDistance, TotalCost
)
SELECT 
    'SHIP001', c.CarrierKey, cont.ContainerKey, st.ShipmentTypeKey,
    p1.PortKey, p2.PortKey,
    20240101, 20240102,
    20240101, 20240102,
    1500.00, 2500.00
FROM 
    DIM_Carrier c, DIM_Container cont, DIM_ShipmentType st,
    DIM_Port p1, DIM_Port p2
WHERE 
    c.CarrierID = 'CAR001'
    AND cont.ContainerID = 'CONT001'
    AND st.ShipmentTypeID = 'ST001'
    AND p1.PortID = 'PORT001'
    AND p2.PortID = 'PORT002';

Select * from FACT_Shipment

INSERT INTO FACT_ShipmentEvent (
    ShipmentKey, EventTypeKey, EventDateKey, PortKey, Duration
)
SELECT 
    s.ShipmentKey, et.EventTypeKey, 20240101, p.PortKey, 120
FROM 
    FACT_Shipment s, DIM_EventType et, DIM_Port p
WHERE 
    s.ShipmentID = 'SHIP001'
    AND et.EventTypeID = 'EVT001'
    AND p.PortID = 'PORT001';

Select * from FACT_ShipmentEvent