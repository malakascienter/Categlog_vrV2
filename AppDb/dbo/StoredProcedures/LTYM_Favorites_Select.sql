
CREATE   PROCEDURE [dbo].[LTYM_Favorites_Select]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT F.Id,
           F.ItemCode,
           F.ItemName,
           CAST(NULL AS INT) AS OutletId,
           L.Description     AS OutletName,
           F.CreatedAt
    FROM   dbo.LTYM_MemberFavorites AS F
    LEFT JOIN dbo.Location AS L ON L.Code = F.OutletCode
    WHERE  F.MemberId = @MemberId
    ORDER BY F.CreatedAt DESC, F.Id DESC;
END

GO

