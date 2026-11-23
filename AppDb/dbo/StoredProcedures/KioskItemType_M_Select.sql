


CREATE   PROCEDURE [dbo].[KioskItemType_M_Select]
    @Id INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, KioskItemType, SortOrder, IsActive
    FROM   dbo.KIOSK_ItemType
    WHERE  (@Id = 0 OR Id = @Id)
    ORDER  BY SortOrder, KioskItemType;
END

GO

