
-- =============================================
-- Description: Select active Special Order sub-types (OrderTypeDetails)
--              for rendering as child channel checkboxes.
-- =============================================
CREATE PROCEDURE [dbo].[SpecialOrderSubType_M_Select]
AS
BEGIN
    SET NOCOUNT ON;

    --SELECT  OTD.OrderTypeId                                  AS OrderTypeId,
    --        -- AppearOnInv is the friendly label (e.g. "General Order", "Corporate Order");
    --        -- fall back to OrderTypeName when it is blank.
    --        ISNULL(NULLIF(LTRIM(RTRIM(OTD.AppearOnInv)), ''), OTD.OrderTypeName) AS Name
    --FROM    OrderTaking..OrderTypeDetails OTD
    --WHERE   OTD.IsActive = 1
    --ORDER BY OTD.OrderTypeId;
END

GO

