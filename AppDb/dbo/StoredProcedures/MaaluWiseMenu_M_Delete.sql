
CREATE PROCEDURE [dbo].[MaaluWiseMenu_M_Delete]
    @PropertyId INT,
    @AggType    INT,
    @MenuCode   VARCHAR(10),
    @Outlet     VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[AggregatorWiseMenuItem]
    WHERE MenuCode     = @MenuCode
      AND AggregatorId = @AggType
      AND PropertyId   = @PropertyId
      AND Outlet       = @Outlet;
END

GO

