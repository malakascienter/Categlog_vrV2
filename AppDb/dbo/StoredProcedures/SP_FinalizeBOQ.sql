--SP_FinalizeBOQ 1,1,29,0,0


CREATE PROCEDURE [dbo].[SP_FinalizeBOQ]
	@CompanyId int,
	@LocationId int,
	@BOQId int,
	@MainBOQId int,
	@versionNo int
AS
   BEGIN TRY
        BEGIN TRANSACTION
	declare @TransactionTypeID int
	
	if @BOQId >0 
	begin
		update BOQHeaders set Finalized =1 where id = @BOQId
	end
	else
	begin
	    select @BOQId =Id from BOQHeaders where MainBoqId = @MainBOQId and VersionNo =@versionNo
		update BOQHeaders set Finalized =1 where id = @BOQId
	end

	  SELECT  @TransactionTypeID = Id
        FROM    TransactionTypes
        WHERE   Code = 'BQ'



	 EXEC dbo.SP_InsertApprovalLevelForRequest @CompanyId, 1,
            @TransactionTypeID, @BOQId
	
		select 1

        COMMIT TRAN -- Transaction Success!
    END TRY
    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN --RollBack in case of  an Error
    END CATCH

GO

