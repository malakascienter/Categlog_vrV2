
CREATE   PROCEDURE [dbo].[LTYM_Favorite_Insert]
    @MemberId   INT,
    @ItemCode   VARCHAR(50),
    @ItemName   NVARCHAR(200),
    @OutletCode VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberFavorites
                   WHERE MemberId = @MemberId AND ItemCode = @ItemCode)
            THROW 52040, 'This item is already in your favourites.', 1;

        INSERT INTO dbo.LTYM_MemberFavorites (MemberId, ItemCode, ItemName, OutletCode)
        VALUES (@MemberId, @ItemCode, @ItemName, @OutletCode);

        SELECT SCOPE_IDENTITY() AS Id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

GO

