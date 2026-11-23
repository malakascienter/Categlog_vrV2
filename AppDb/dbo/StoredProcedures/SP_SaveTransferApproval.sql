-- =============================================
-- Author:        Vinuki
-- Create date:   26.04.2024
-- Description:   Save Transfer Approval
-- =============================================
CREATE PROCEDURE [dbo].[SP_SaveTransferApproval](@XMLData AS XML, @TransactionID INT) 
AS
    DECLARE @iDocID INT 
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

       
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;
		Declare @SeqIDOld int = 0  , @ApprovalUserIDOld int = 0 , @ApprovalUserIDNew int = 0  , @RowCount INT = 1, @TotalRows INT, @HeaderID Int , @DocumentNo varchar(255);
       ---------------------------- adding the values to a table from xml ---------------------------------------
        SELECT  *
        INTO    #DataObtained
        FROM    OPENXML (@iDocID, 'ArrayOfUpdateTransactionsApprovalUser/UpdateTransactionsApprovalUser', 2) WITH (
                    HeaderID INT,
                    TransactionID INT,
                    LocationOrDepartmentID INT,
                    SupplierID INT,
                    ApprovalUserIDOld INT,
                    ApprovalUserNew INT,
					DocumentNo varchar(255)
                );

      -------------------------------------------------------------------------------------------------------------
        SELECT * FROM #DataObtained;
		SELECT @TotalRows = COUNT(*) FROM #DataObtained;
		-------------------- assging values ------------------------------------
		select top 1 @ApprovalUserIDOld = ApprovalUserIDOld from #DataObtained
		select top 1 @ApprovalUserIDNew = ApprovalUserNew from #DataObtained
		-------------------------------------------------------------------------

		select @ApprovalUserIDOld ApprovalUserIDOld
		select @ApprovalUserIDNew ApprovalUserIDNew

		IF ( @TransactionID = 1 OR  @TransactionID = 2 OR   @TransactionID = 8 OR   @TransactionID = 11 OR   @TransactionID = 14   )
		begin 
		select 8888888888
			WHILE @RowCount <= @TotalRows
				begin
		
				SELECT @HeaderID = HeaderID
			
				FROM (
				SELECT 
						HeaderID,
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM #DataObtained
    ) AS SubQuery
    WHERE RowNum = @RowCount;


		select @HeaderID HeaderID
		select @SeqIDOld = SeqID from ApprovalLogs where TransactionHeaderID = @HeaderID and ApprovalUserID = @ApprovalUserIDOld
		select * from ApprovalLogs where TransactionHeaderID = @HeaderID and SeqID = @SeqIDOld and ApprovalUserID != @ApprovalUserIDOld
		---------------updation for transactionid = 2 ----------------------------------------------------------------------------------------------------------------
		if exists (select * from ApprovalLogs where TransactionHeaderID = @HeaderID and SeqID = @SeqIDOld and ApprovalUserID = @ApprovalUserIDOld )
		begin
		select 99999999999
		update ApprovalLogs
		set ApprovalUserID = @ApprovalUserIDNew
		where TransactionHeaderID = @HeaderID and SeqID = @SeqIDOld and  ApprovalUserID = @ApprovalUserIDOld
		end
		---------------------------------------------------------------------------------------------------------------------------------------------------------------
		SET @RowCount = @RowCount + 1;
				end
		end



		IF ( @TransactionID = 3 OR  @TransactionID = 4  OR   @TransactionID = 10 )
		BEGIN
		select 43434343434

				
			WHILE @RowCount <= @TotalRows
			BEGIN
				SELECT @DocumentNo = DocumentNo
				FROM (
					SELECT 
						DocumentNo,
						ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
					FROM #DataObtained
				) AS SubQuery
				WHERE RowNum = @RowCount;

	select @DocumentNo DocumentNo

		SELECT @seqidOld = SeqID FROM GRNApprovalLog where ApprovalDocNo = @DocumentNo and UserProfileId = @ApprovalUserIDOld
		select @seqidOld

		select * from GRNApprovalLog where ApprovalDocNo = @DocumentNo and SeqID = @seqidOld and UserProfileId != @ApprovalUserIDOld

		if exists(select * from GRNApprovalLog where ApprovalDocNo = @DocumentNo and SeqID = @seqidOld and UserProfileId = @ApprovalUserIDOld)
		begin
		update GRNApprovalLog
		set UserProfileId = @ApprovalUserIDNew
		
		where ApprovalDocNo = @DocumentNo and SeqID = @seqidOld and UserProfileId = @ApprovalUserIDOld
		end
		SET @RowCount = @RowCount + 1;
				end

		END







        DROP TABLE #DataObtained;
        EXEC sp_xml_removedocument @iDocID;

       
        COMMIT TRANSACTION;
    END TRY


    BEGIN CATCH
      
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY()
          

      
        ROLLBACK TRANSACTION;

     
        IF @iDocID IS NOT NULL
        BEGIN
            EXEC sp_xml_removedocument @iDocID;
        END

      
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

