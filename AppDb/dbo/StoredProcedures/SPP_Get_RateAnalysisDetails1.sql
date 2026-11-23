
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SPP_Get_RateAnalysisDetails1 7
CREATE PROCEDURE [dbo].[SPP_Get_RateAnalysisDetails1]
    -- Add the parameters for the stored procedure here
    @RateAnalysisHeaderID INT
AS
BEGIN
    DECLARE @TEMP TABLE
    (
        Id INT,
        RateAnalysisHeaderID INT,
        SequNo INT,
        LocationID INT,
        ItemHeaderID INT,
        UnitID INT,
        UnitPrice DECIMAL(18, 2),
        Quantity DECIMAL(18, 2),
        ProfitMarginVal DECIMAL(18, 2),
        OverheadCostVal DECIMAL(18, 2),
        isDisRate BIT,
        isProjectspecificSubstituteItem BIT,
        DisValue DECIMAL(18, 2),
        ItemType NVARCHAR(MAX),
        Name NVARCHAR(MAX),
        ItemName NVARCHAR(MAX),
        LocationName NVARCHAR(MAX),
		CostPercentage Decimal(18,2),
		UnitTax Decimal(18,2)
    );
    --DECLARE @TEMP2 AS TABLE ( ID INT IDENTITY(1,1),ItemType VARCHAR(1)  )
    --insert into @temp SELECT ID, Name FROM Table
    --DECLARE @Type nvarchar(max),@count INT = 1

    --INSERT INTO @TEMP2
    --SELECT  ItemType FROM RateAnalysisDetails WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID

    --WHILE (@count <= (SELECT COUNT(1) FROM @TEMP2 ))
    --BEGIN

    --SELECT @Type = ItemType FROM @TEMP2 WHERE id = @count

    --IF @Type='I'
    --BEGIN
    --SELECT @Type AS Type
    INSERT @TEMP
    (
        Id,
        RateAnalysisHeaderID,
        SequNo,
        LocationID,
        ItemHeaderID,
        UnitID,
        UnitPrice,
        Quantity,
        ProfitMarginVal,
        OverheadCostVal,
        isDisRate,
        DisValue,
        isProjectspecificSubstituteItem,
        ItemType,
        Name,
        ItemName,
        LocationName,
		CostPercentage
    )
    SELECT dbo.RateAnalysisDetails.Id,
           dbo.RateAnalysisDetails.RateAnalysisHeaderID,
           dbo.RateAnalysisDetails.SequNo,
           dbo.RateAnalysisDetails.LocationID,
           dbo.RateAnalysisDetails.ItemHeaderID,
           dbo.RateAnalysisDetails.UnitID,
           dbo.RateAnalysisDetails.UnitPrice,
           dbo.RateAnalysisDetails.Quantity,
           dbo.RateAnalysisDetails.ProfitMarginVal,
           dbo.RateAnalysisDetails.OverheadCostVal,
           dbo.RateAnalysisDetails.isDisRate,
           dbo.RateAnalysisDetails.DisValue,
           dbo.RateAnalysisDetails.isProjectspecificSubstituteItem,
           dbo.RateAnalysisDetails.ItemType,
           dbo.Units.Name,
           dbo.StockItemHeaders.Name AS ItemName,
           dbo.Locations.Name AS LocationName,
		   costprovisions.Percentage as CostPercentage
    FROM dbo.RateAnalysisDetails
        INNER JOIN dbo.StockItemHeaders
            ON dbo.RateAnalysisDetails.ItemHeaderID = dbo.StockItemHeaders.Id
        INNER JOIN dbo.Units
            ON dbo.RateAnalysisDetails.UnitID = dbo.Units.Id
        INNER JOIN dbo.Locations
            ON dbo.RateAnalysisDetails.LocationID = dbo.Locations.Id
		LEFT JOIN costprovisions 
		    ON  costprovisions.ItemId=dbo.RateAnalysisDetails.ItemHeaderID and RateAnalysisDetails.RateAnalysisHeaderID = costprovisions.RateHeaderId
    WHERE (
              dbo.RateAnalysisDetails.RateAnalysisHeaderID = @RateAnalysisHeaderID
              AND ItemType = 'I'
          )
    UNION ALL
    SELECT dbo.RateAnalysisDetails.Id,
           dbo.RateAnalysisDetails.RateAnalysisHeaderID,
           dbo.RateAnalysisDetails.SequNo,
           0,
           dbo.RateAnalysisDetails.ItemHeaderID,
           dbo.RateAnalysisDetails.UnitID,
           dbo.RateAnalysisDetails.UnitPrice,
           dbo.RateAnalysisDetails.Quantity,
           dbo.RateAnalysisDetails.ProfitMarginVal,
           dbo.RateAnalysisDetails.OverheadCostVal,
           dbo.RateAnalysisDetails.isDisRate,
           dbo.RateAnalysisDetails.isProjectspecificSubstituteItem,
           dbo.RateAnalysisDetails.DisValue,
           'L',
           LU.LaborUnitName,
           dbo.LabourTypes.LabourName,
           '',
		   0 as CostPercentage
    FROM dbo.LabourTypes
        INNER JOIN dbo.RateAnalysisDetails
            ON dbo.LabourTypes.Id = dbo.RateAnalysisDetails.ItemHeaderID
        INNER JOIN dbo.LaborUnits LU
            ON LU.Id = dbo.RateAnalysisDetails.UnitID
    WHERE (
              dbo.RateAnalysisDetails.RateAnalysisHeaderID = @RateAnalysisHeaderID
              AND ItemType = 'L'
          )
    UNION ALL
    SELECT dbo.RateAnalysisDetails.PackID,
           dbo.RateAnalysisDetails.RateAnalysisHeaderID,
           MIN(dbo.RateAnalysisDetails.SequNo),
           0,
           dbo.RateAnalysisDetails.PackID,
           dbo.RateAnalysisDetails.UnitID,
           AVG(dbo.RateAnalysisDetails.UnitPrice),
           dbo.RateAnalysisDetails.PackQty,
           SUM(dbo.RateAnalysisDetails.ProfitMarginVal),
           SUM(dbo.RateAnalysisDetails.OverheadCostVal),
           dbo.RateAnalysisDetails.isDisRate,
           dbo.RateAnalysisDetails.isProjectspecificSubstituteItem,
           SUM(dbo.RateAnalysisDetails.DisValue),
           'L',
           '',
           dbo.BOQPackages.Description,
           '',
		   0 as CostPercentage
    FROM dbo.BOQPackages
        INNER JOIN dbo.RateAnalysisDetails
            ON dbo.BOQPackages.Id = dbo.RateAnalysisDetails.PackID
    WHERE (
              dbo.RateAnalysisDetails.RateAnalysisHeaderID = @RateAnalysisHeaderID
              AND ItemType = 'P'
          )
    GROUP BY dbo.RateAnalysisDetails.PackID,
             dbo.RateAnalysisDetails.RateAnalysisHeaderID,
             dbo.RateAnalysisDetails.PackID,
             dbo.RateAnalysisDetails.UnitID,
             dbo.RateAnalysisDetails.PackQty,
             dbo.RateAnalysisDetails.isProjectspecificSubstituteItem,
             dbo.BOQPackages.Description,
             dbo.RateAnalysisDetails.isDisRate;


    SELECT *
    FROM @TEMP
    ORDER BY SequNo;


-- select * from RateAnalysisDetails
--END 
--ELSE	
--BEGIN
--SELECT @Type

--INSERT @TEMP
--	( Id ,
--	  RateAnalysisHeaderID ,
--	  SequNo ,
--	  LocationID ,
--	  ItemHeaderID ,
--	  UnitID ,
--	  UnitPrice ,
--	  Quantity ,
--	  ProfitMarginVal ,
--	  OverheadCostVal ,
--	  isDisRate ,
--	  DisValue ,
--	  ItemType ,
--	  Name ,
--	  ItemName ,
--	  LocationName
--	)



--END

--SET @count +=1;

--END

END;

GO

