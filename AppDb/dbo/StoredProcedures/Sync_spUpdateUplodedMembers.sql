



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedMembers]

@Memberid INT
AS

UPDATE	Members SET IsUpload = 1 WHERE id = @Memberid

GO

