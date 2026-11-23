
CREATE PROCEDURE dbo.CSOX_PaymentTypes_Select
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT   PayCode       AS PayCode,
             [Description] AS [Description],
             Cash          AS IsCash,
             IsAdvance     AS IsAdvance,
             ISNULL(SortOrder, 9999) AS SortOrder
    FROM     dbo.PaymentTypes
    WHERE    PropertyId = @PropertyId
      AND    Active = 1
    ORDER BY ISNULL(SortOrder, 9999), PayCode;
END

GO

