
CREATE   PROCEDURE [dbo].[LTYM_Promotions_Birthday]

AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    SELECT TOP (1)
           P.PromotionId              AS Id,
           P.PromotionName            AS HeaderText,
           P.Description              AS ContentText,
           P.ImageURL                 AS ImageWebPath,
           P.Discount                 AS Discount,
           P.IsDiscountPercentage     AS IsPercentage,
           CAST(NULL AS VARCHAR(50))  AS DiscountCode
    FROM   dbo.LTY_Promotion AS P
    WHERE  P.PropertyId = @PropertyId
      AND  P.IsActive   = 1
      AND (P.IsBirthdayDate = 1 OR P.IsBirthdayMonth = 1)
      AND  CAST(GETDATE() AS DATE) BETWEEN P.StartDate AND P.EndDate
    ORDER BY P.PromotionId DESC;
END

GO

