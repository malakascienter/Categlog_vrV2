
CREATE   PROCEDURE [dbo].[LTYM_Favorite_Delete]
    @MemberId INT,
    @Id       INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.LTYM_MemberFavorites
    WHERE  Id = @Id AND MemberId = @MemberId;
END

GO

