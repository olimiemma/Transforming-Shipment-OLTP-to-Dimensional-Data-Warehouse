--What's the average cost of shipments by carrier and container type?
SELECT 
    c.CarrierName,
    cont.ContainerType,
    cont.ContainerSize,
    COUNT(*) as number_of_shipments,
    ROUND(AVG(fs.TotalCost), 2) as average_cost,
    ROUND(MIN(fs.TotalCost), 2) as min_cost,
    ROUND(MAX(fs.TotalCost), 2) as max_cost
FROM FACT_Shipment fs
JOIN DIM_Carrier c ON fs.CarrierKey = c.CarrierKey
JOIN DIM_Container cont ON fs.ContainerKey = cont.ContainerKey
GROUP BY c.CarrierName, cont.ContainerType, cont.ContainerSize
ORDER BY c.CarrierName, average_cost DESC;



--Show me transit times and costs for each route (origin to destination):
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



--Show me event durations by carrier and event type:
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




----- Analyze shipment patterns: Cost per distance ratio and average costs by region
/*This query will:
-Group shipments by origin and destination regions
-Calculate cost efficiency (cost per distance unit)
-Show cost ranges for each region pair

This is interesting because:
We can see which regional routes are most expensive
We can compare cost efficiency between different routes
We can identify the price ranges for different regions
*/
SELECT 
    op.Region as origin_region,
    dp.Region as destination_region,
    COUNT(*) as number_of_shipments,
    ROUND(AVG(fs.TotalCost), 2) as average_cost,
    ROUND(AVG(fs.TotalDistance), 2) as average_distance,
    ROUND(AVG(fs.TotalCost/fs.TotalDistance), 2) as cost_per_distance_unit,
    MIN(fs.TotalCost) as min_cost,
    MAX(fs.TotalCost) as max_cost
FROM FACT_Shipment fs
JOIN DIM_Port op ON fs.OriginPortKey = op.PortKey
JOIN DIM_Port dp ON fs.DestinationPortKey = dp.PortKey
GROUP BY 
    op.Region,
    dp.Region
ORDER BY 
    number_of_shipments DESC,
    average_cost DESC;



--Which ports have the most delayed shipments?
SELECT 
    p.PortName,
    p.Country,
    COUNT(*) as total_shipments,
    COUNT(CASE 
        WHEN (act.FullDate > sched.FullDate) 
        THEN 1 END) as delayed_shipments,
    ROUND(COUNT(CASE 
        WHEN (act.FullDate > sched.FullDate) 
        THEN 1 END) * 100.0 / COUNT(*), 2) as delay_percentage
FROM FACT_Shipment fs
JOIN DIM_Port p ON fs.OriginPortKey = p.PortKey
JOIN DIM_Date sched ON fs.ScheduledEndDateKey = sched.DateKey
JOIN DIM_Date act ON fs.ActualEndDateKey = act.DateKey
GROUP BY p.PortName, p.Country
HAVING COUNT(*) > 5  -- Only show ports with more than 5 shipments
ORDER BY delay_percentage DESC;






---Event Duration Analysis:
SELECT 
    det.EventTypeName,
    dp.Region,
    AVG(fse.Duration) as avg_duration,
    COUNT(*) as event_count
FROM FACT_ShipmentEvent fse
JOIN DIM_EventType det ON fse.EventTypeKey = det.EventTypeKey
JOIN DIM_Port dp ON fse.PortKey = dp.PortKey
GROUP BY det.EventTypeName, dp.Region;