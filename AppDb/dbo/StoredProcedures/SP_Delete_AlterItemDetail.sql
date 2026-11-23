CREATE PROCEDURE [dbo].[SP_Delete_AlterItemDetail] -- SP_Delete_AlterItemDetail 46,38
		@GroupID INT,
		@ItemID INT
		
AS
BEGIN

 DECLARE @userid INT
    SELECT @userid = CreatedUserID FROM AltItemGroupDetails WHERE GroupID = @GroupID AND ID = @ItemID

	if exists ( select 1 from  AltItemGroupDetails WHERE GroupID = @GroupID AND ID = @ItemID) 
	begin
    EXEC Inventry_AuditTail_WriteToLog 'AltItemGroupDetails', @ItemID, 'INV', 'AIGDD', 'D', @userid, 0, '', ''
    DELETE FROM AltItemGroupDetails WHERE GroupID = @GroupID AND ID = @ItemID
	end 
END

GO

