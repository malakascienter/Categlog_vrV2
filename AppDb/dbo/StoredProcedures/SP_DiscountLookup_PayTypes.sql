CREATE PROCEDURE dbo.SP_DiscountLookup_PayTypes
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LTRIM(RTRIM(P.PayCode)) AS Code,
           P.Description           AS Name
      FROM dbo.PaymentTypes P
     WHERE P.Active = 1
       AND P.PropertyId = @PropertyId
     ORDER BY P.PayCode;
END

GO

