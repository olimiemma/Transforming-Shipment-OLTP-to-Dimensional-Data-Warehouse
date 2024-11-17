# Shipping Data Warehouse Project

A dimensional data warehouse design for tracking and analyzing global shipping operations, including shipment tracking, event monitoring, and cost analysis.


![image](https://github.com/user-attachments/assets/7d3bfbe4-2e99-4d06-adac-41ae1a479c1d)

![image](https://github.com/user-attachments/assets/f83b7c96-a58b-4c28-9580-daab574d3478)

## Overview

This project transforms an OLTP shipping database into a dimensional data warehouse model, enabling efficient analysis of:
- Shipment routes and costs
- Event durations and patterns
- Carrier performance
- Regional shipping patterns
- Cost efficiency across routes

## Data Model

### Dimension Tables

#### DIM_Date
- Primary date dimension for temporal analysis
- Attributes: Year, Quarter, Month, MonthName, DayOfWeek, DayName, IsWeekend, FiscalYear

#### DIM_Carrier
- Tracks shipping carriers and their details
- Type 2 SCD (Slowly Changing Dimension)
- Key attributes: CarrierName, ValidFrom, ValidTo, IsCurrent

#### DIM_Container
- Container specifications and types
- Type 2 SCD
- Key attributes: ContainerType, ContainerSize

#### DIM_Port
- Global ports and their geographic hierarchy
- Type 2 SCD
- Key attributes: PortName, Country, Region

#### DIM_ShipmentType
- Types of shipments (FCL, LCL, etc.)
- Type 2 SCD
- Includes:
  - FCL (Full Container Load)
  - LCL (Less than Container Load)
  - RORO (Roll-On/Roll-Off)
  - BULK
  - BREAKBULK
  - REEFER
  - DG (Dangerous Goods)
  - PROJECT

#### DIM_EventType
- Types of events in shipping lifecycle
- Type 2 SCD
- Key attributes: EventTypeName, EventCategory

### Fact Tables

#### FACT_Shipment
- Grain: One record per shipment
- Measures:
  - TotalDistance
  - TotalCost
- Key dates:
  - Scheduled Start/End
  - Actual Start/End

#### FACT_ShipmentEvent
- Grain: One record per event within a shipment
- Measures:
  - Duration (minutes)
- Links events to shipments and locations

## Schema Design

The data warehouse uses a star schema design for:
- Simplified querying
- Improved query performance
- Easier maintenance
- Denormalized dimension tables

## Example Analyses

### 1. Event Duration Analysis
```sql
SELECT 
    c.CarrierName,
    et.EventTypeName,
    et.EventCategory,
    COUNT(*) as number_of_events,
    ROUND(AVG(fse.Duration), 2) as average_duration_minutes,
    MIN(fse.Duration) as min_duration,
    MAX(fse.Duration) as max_duration
FROM FACT_ShipmentEvent fse
JOIN FACT_Shipment fs ON fse.ShipmentKey = fs.ShipmentKey
JOIN DIM_Carrier c ON fs.CarrierKey = c.CarrierKey
JOIN DIM_EventType et ON fse.EventTypeKey = et.EventTypeKey
GROUP BY 
    c.CarrierName,
    et.EventTypeName,
    et.EventCategory
ORDER BY 
    c.CarrierName,
    average_duration_minutes DESC;
```

### 2. Route Cost Analysis
```sql
SELECT 
    op.PortName as origin_port,
    op.Country as origin_country,
    dp.PortName as destination_port,
    dp.Country as destination_country,
    COUNT(*) as number_of_shipments,
    ROUND(AVG(fs.TotalCost), 2) as average_cost,
    ROUND(AVG(fs.TotalDistance), 2) as average_distance
FROM FACT_Shipment fs
JOIN DIM_Port op ON fs.OriginPortKey = op.PortKey
JOIN DIM_Port dp ON fs.DestinationPortKey = dp.PortKey
GROUP BY 
    op.PortName, op.Country,
    dp.PortName, dp.Country
ORDER BY number_of_shipments DESC;
```

### 3. Regional Cost Efficiency
```sql
SELECT 
    op.Region as origin_region,
    dp.Region as destination_region,
    COUNT(*) as number_of_shipments,
    ROUND(AVG(fs.TotalCost), 2) as average_cost,
    ROUND(AVG(fs.TotalDistance), 2) as average_distance,
    ROUND(AVG(fs.TotalCost/fs.TotalDistance), 2) as cost_per_distance_unit
FROM FACT_Shipment fs
JOIN DIM_Port op ON fs.OriginPortKey = op.PortKey
JOIN DIM_Port dp ON fs.DestinationPortKey = dp.PortKey
GROUP BY 
    op.Region,
    dp.Region
ORDER BY 
    number_of_shipments DESC,
    average_cost DESC;
```

## Key Insights From Sample Data

1. **Event Patterns**
   - Terminal operations (Gate In): 90-120 minutes
   - Vessel Departure: 150 minutes
   - Vessel Arrival: 120 minutes
   - Consistent timing across carriers

2. **Route Costs**
   - Most expensive: Rotterdam → Los Angeles ($4,500)
   - Most efficient: Europe → North America (1.29 cost/distance)
   - Least efficient: Asia → Europe (1.67 cost/distance)

3. **Regional Patterns**
   - Asia is a major origin point
   - Long-distance routes more cost-efficient
   - Intra-regional shipping shows medium efficiency

## Setup Instructions

1. Create database tables using provided DDL scripts
2. Load dimension tables first
3. Load fact tables with referential integrity
4. Run sample queries to verify setup

## Database Requirements

- PostgreSQL database
- Supports Type 2 SCD
- Referential integrity enforcement
- Appropriate indexing for fact table foreign keys

## Future Enhancements

1. Additional dimensions:
   - Customer dimension
   - Time of day dimension
   - Weather conditions
2. Additional metrics:
   - Fuel consumption
   - CO2 emissions
   - Capacity utilization
3. Real-time event tracking
4. Predictive analytics capabilities

## Contributing

Feel free to contribute to this project by:
1. Adding more analytical queries
2. Enhancing the data model
3. Improving documentation
4. Adding data quality checks

## License

MIT License - feel free to use and modify for your needs.
