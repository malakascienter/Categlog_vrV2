
CREATE   PROCEDURE [dbo].[LTYM_Promotions_Select]

AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    SELECT P.PromotionId            AS Id,
           P.PromotionName          AS Name,
           CAST(NULL AS VARCHAR(50)) AS DiscountCode,
           P.Discount               AS DiscountPercentage,
           P.IsDiscountPercentage   AS IsPercentage,
           CAST(P.StartDate AS DATETIME) AS FromDate,
           CAST(P.EndDate   AS DATETIME) AS ToDate,
           STUFF((SELECT ', ' + D.Days
                  FROM   dbo.LTY_DayWisePromotion D
                  WHERE  D.PromotionId = P.PromotionId
                  FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')      AS DiscountDays,
           STUFF((SELECT ', ' + L.LocationCode
                  FROM   dbo.LTY_LocationWisePromotion L
                  WHERE  L.PromotionId = P.PromotionId
                  FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')      AS OutletList
    FROM   dbo.LTY_Promotion AS P
    WHERE  P.PropertyId = @PropertyId
      AND  P.IsActive   = 1
      AND  P.IsBirthdayDate  = 0
      AND  P.IsBirthdayMonth = 0
      AND  CAST(GETDATE() AS DATE) BETWEEN P.StartDate AND P.EndDate
    ORDER BY P.StartDate DESC, P.PromotionId DESC;
END

GO

