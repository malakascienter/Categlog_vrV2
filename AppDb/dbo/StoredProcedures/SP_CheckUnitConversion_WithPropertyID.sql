
-- [dbo].[SP_CheckUnitConversion_WithPropertyID] 'NUMBERS', 1,'003',1
create  PROCEDURE [dbo].[SP_CheckUnitConversion_WithPropertyID]
    @unitName VARCHAR(50),
    @PropertyID INT,
	@StockItemCode VARCHAR(100),
	@LocationID INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH tempTable AS (
        SELECT 
            ToUnitID AS UnitID,
            ToUnitName AS UnitName,
            Value
        FROM dbo.UnitConversions
        WHERE FromUnitName = @unitName AND CompanyId = @PropertyID

        UNION ALL

        SELECT 
            FromUnitID AS UnitID,
            FromUnitName AS UnitName,
            Value
        FROM dbo.UnitConversions
        WHERE ToUnitName = @unitName AND CompanyId = @PropertyID

        UNION

        SELECT 
            Id AS UnitID,
            Name AS UnitName,
            1 AS Value
        FROM dbo.Units
        WHERE Name = @unitName
    )
     (SELECT * INTO #tempTable2 FROM tempTable)


	 
	 IF EXISTS( 	SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
	dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
	dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode AND SD.LocationID= @LocationID
	and U.Name in( SELECT UnitName from #tempTable2))
	 BEGIN
		SELECT 1
	 END
	 ELSE
	 BEGIN
		SELECT 0
	 END
   
END

GO

