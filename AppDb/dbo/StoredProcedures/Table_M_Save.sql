-- =============================================
-- Author:		Chiraj
-- Create date: 2020-07-7
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Table_M_Save]
	@Id INT,
	@TableCategoryID INT,
	@TableName VARCHAR(50),
	@IsActive BIT,
	@UserId INT,
	@PropertyId INT,
	@Operation CHAR(1),
	@SeatCount INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		SET NOCOUNT ON;
		DECLARE @Remark NVARCHAR(250)
		DECLARE @TablelastId		INT
		IF @Operation ='I'  
		BEGIN 
			IF EXISTS (SELECT 1 FROM POS_TableList where PropertyId=@PropertyId AND TableCategoryID=@TableCategoryID AND TableName=@TableName AND MarkAsDelete=0)         
			BEGIN  
				RAISERROR('Table  Name already in the selected category',16,1)  
			END  
			ELSE 
			BEGIN 					
			
				-- audit trail	 
				EXEC [dbo].[AuditTrail_InsertToHistory] 'POS_TableList',@Id
				-- end of audit trail

				INSERT INTO POS_TableList(TableCategoryID, TableName, IsActive, SequenceID,PropertyId,MarkAsDelete,IsUpload,CreatedUserID ,CreatedDateTime,SeatCount,AvailableChairs)
				values (@TableCategoryID,@TableName,@IsActive,((select Isnull(max(SequenceID),0)from POS_TableList WHERE PropertyId=@PropertyId)+1),@PropertyId,0,0,@UserId,GETDATE(),@SeatCount,@SeatCount)  
				SET @TablelastId = SCOPE_IDENTITY() 

				-- Audit trail ----------------------------		
				EXEC HotelResWeb_AuditTail_WriteToLog 'POS_TableList',@TablelastId,'POS','POSTTI','I',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------
				 
				 SELECT * FROM POS_TableList WHERE PropertyId=@PropertyId  AND TableID=@TablelastId
				-- audit trail				
				SET @Remark = 'POS_TableList '+@TableName+' created.';
				EXEC [dbo].[AuditTrail_InsertTableChanges] 'POS_TableList',@Id,@UserId,'I',@Remark
				-- end of audit trail	
			END     
		END 
		--ELSE IF @Operation='U'
		--BEGIN
		--	UPDATE POS_TableList SET
		--	TableCategoryID=TableCategoryID,
		--	TableName=@TableName,
		--	IsActive=@IsActive,
		--	IsUpload=0
		--	WHERE TableCategoryID=@Id  AND PropertyId=@PropertyId
		--END

		EXEC Insert_Sync_MasterDataTransferStatus 'Table',@IsActive,@TablelastId,@PropertyId
    
COMMIT TRANSACTION
	END TRY
	BEGIN CATCH	
		ROLLBACK TRANSACTION
		INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
	END CATCH
    
END

GO

