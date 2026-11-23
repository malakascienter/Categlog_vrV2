CREATE PROCEDURE [dbo].[SP_Delete_All_AlterItem] --2
		@GroupID INT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION

	 DECLARE @userid INT
	 DECLARE @userid2 INT

    SELECT @userid = CreatedUserID FROM AltItemGroups WHERE id = @GroupID

	if exists ( select 1 from AltItemGroups where id = @GroupID)
		begin
 	EXEC Inventry_AuditTail_WriteToLog 'AltItemGroups', @GroupID, 'INV', 'AIGD', 'D', @userid, 0, '', ''
	delete  from AltItemGroups where id = @GroupID

		end

	SELECT @userid2 = CreatedUserID FROM AltItemGroupDetails WHERE GroupID =  @GroupID

	if exists ( select 1 from  AltItemGroupDetails where GroupID =  @GroupID)
	begin
	EXEC Inventry_AuditTail_WriteToLog 'AltItemGroupDetails', @GroupID, 'INV', 'AIGDD', 'D', @userid2, 0, '', ''
	delete from AltItemGroupDetails where GroupID =  @GroupID --AND ItemId = @ItemID
	end

	
	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH





END

GO

