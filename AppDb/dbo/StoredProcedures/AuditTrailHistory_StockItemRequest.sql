-- =============================================
-- Author:		<Vinuki>
-- Create date: <25.03.2024>
-- Description:	<Description,,>
-- =============================================
-- AuditTrailHistory_StockItemRequest 143
create PROCEDURE [dbo].[AuditTrailHistory_StockItemRequest]

	@StockItemID INT
	
AS
BEGIN

	SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#AuditTrailID') IS NOT NULL
    DROP TABLE #AuditTrailID;

IF OBJECT_ID('tempdb..#DataSet') IS NOT NULL
    DROP TABLE #DataSet;

SELECT *
INTO #AuditTrailID
FROM (
    SELECT AuditTrailID
    FROM HotelResWeb_AuditTail..TempStockItemRequest_History
    WHERE Id = @StockItemID

    --UNION

    --SELECT AuditTrailID
    --FROM HotelResWeb_AuditTail..TempStockItemRequestWiseLocations_History
    --WHERE StockItemRequestId = @StockItemID
) AS UnionResult;

select * into #locationTable
from
(

		select distinct HTSIR.LocationId,(select top 1 Name from Categlog_vrV2.. Locations where Id = HTSIR.LocationId)Name, StockItemRequestId, FORMAT(HTSIR.AuditLoggedTxnDateTime, 'dd:MM:yy HH:mm:ss')    as DateAndTime ,
		 CASE
	 WHEN Action = 'I' THEN 'Created'
	 WHEN Action = 'U' THEN 'Updated'
	 WHEN Action = 'D' THEN 'Deleted' END Action
	 from HotelResWeb_AuditTail..TempStockItemRequestWiseLocations_History HTSIR
	inner join HotelResWeb_AuditTail..AuditTrailMaster atm
	ON HTSIR.AuditTrailID = ATM.TrailID 
	left join HotelResWeb_AuditTail..TempStockItemRequest_History a
	on  a.id = HTSIR.StockItemRequestId
	where HTSIR.StockItemRequestId = @StockItemID
	and FORMAT(a.AuditLoggedTxnDateTime, 'dd:MM:yy HH:mm:ss') =FORMAT(HTSIR.AuditLoggedTxnDateTime, 'dd:MM:yy HH:mm:ss') 
	
)
as Test;




select ADHT.AuditTrailID, ATM.PropertyId,ItemCode,ItemDescription,atm.LogDate,

 UserID, TableName, FieldName, OldValue, NewValue ,
 CASE
 WHEN Action = 'I' THEN 'Created'
 WHEN Action = 'U' THEN 'Updated'
 WHEN Action = 'D' THEN 'Deleted' END Action,


    (CASE 
        WHEN FieldName = 'ItemUnit' THEN (SELECT TOP 1 name FROM units WHERE id =ATD.OldValue )
        WHEN FieldName = 'CategoryId' THEN (SELECT TOP 1 name FROM Categories WHERE id =ATD.OldValue)
        WHEN FieldName = 'SubCategoryId' THEN (SELECT TOP 1 name FROM SubCategories WHERE id =ATD.OldValue)
        WHEN FieldName = 'SubCategory2Id' THEN (SELECT TOP 1 Description FROM SubCategories02 WHERE id = ATD.OldValue) 
    END) AS FieldNameOLD,
    (CASE 
        WHEN FieldName = 'ItemUnit' THEN (SELECT TOP 1 name FROM units WHERE id = ATD.NewValue)
        WHEN FieldName = 'CategoryId' THEN (SELECT TOP 1 name FROM Categories WHERE id = ATD.NewValue)
        WHEN FieldName = 'SubCategoryId' THEN (SELECT TOP 1 name FROM SubCategories WHERE id =ATD.NewValue )
        WHEN FieldName = 'SubCategory2Id' THEN (SELECT TOP 1 Description FROM SubCategories02 WHERE id = ATD.NewValue)
    END) AS FieldNameNew
	
	

	 INTO #DataSet


from #AuditTrailID ADHT 

inner join Categlog_vrV2..TempStockItemRequest TSIR on TSIR.Id = @StockItemID

inner join HotelResWeb_AuditTail..AuditTrailMaster ATM on ATM.TrailID = ADHT.AuditTrailID
left join HotelResWeb_AuditTail..AuditTrailDetail ATD on ATD.TrailID = ADHT.AuditTrailID 


SELECT DS.AuditTrailID, DS.Action, DS.logDate, DS.TableName, DS.PropertyId, DS.ItemCode,DS.ItemDescription,
(
    SELECT * FROM #DataSet DST WHERE DST.AuditTrailID = DS.AuditTrailID and dst.FieldName is not null FOR JSON PATH
) AS AuditTrailData,
(
    SELECT * FROM #locationTable TempLoc where tempLoc.DateAndTime = FORMAT(ds.LogDate, 'dd:MM:yy HH:mm:ss')   FOR JSON PATH
) AS AuditTTrailLocationList
FROM #DataSet DS
GROUP BY DS.AuditTrailID, DS.logDate, DS.Action, DS.TableName, DS.PropertyId, DS.ItemCode,DS.ItemDescription
ORDER BY DS.logDate DESC




END

GO

