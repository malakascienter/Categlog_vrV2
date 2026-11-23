
CREATE PROCEDURE [dbo].[Maalu_UploadStatus_Update]
    @All        BIT,
    @PropertyId INT,
    @Outlet     VARCHAR(5),
    @ItemCode   VARCHAR(10),
    @AggType    INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE MM
       SET MM.IsUploadToMaalu = 1
      FROM dbo.AggregatorWiseMenuItem A
      INNER JOIN dbo.MainMenu MM
          ON A.MenuCode = MM.ItemCode AND A.PropertyId = MM.PropertyId
     WHERE A.Outlet       = @Outlet
       AND A.PropertyId   = @PropertyId
       AND A.AggregatorId = @AggType
       AND (@All = 1 OR MM.ItemCode = @ItemCode);

    SELECT CAST(1 AS BIT) AS Result;
END

GO

