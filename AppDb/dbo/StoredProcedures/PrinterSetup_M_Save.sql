
-- =============================================
-- Author:		Chiraj	
-- Create date: 2018-10-31
-- Description:	Save printer details
-- =============================================
CREATE PROCEDURE [dbo].[PrinterSetup_M_Save] 
@Code				VARCHAR(2),
@Name				VARCHAR(50),
@Printer			VARCHAR(50),
@Path				NVARCHAR(MAX),
@TicketNo			INT=1, 
@PrintTicket		BIT,
@AlternativePrinter VARCHAR(50),
@Active				BIT,
@Operation			CHAR(1),
@UserId				INT,
@PropertyId			INT
AS
BEGIN	
	DECLARE @Remark NVARCHAR(250)	 
	SET NOCOUNT ON;

	IF @Operation ='I'  
	BEGIN  
		IF EXISTS (SELECT 1 FROM PrinterSetup where PropertyId=@PropertyId AND (code=@Code OR Printer=@Printer))         
		BEGIN  
			RAISERROR('Printer already exists45454',16,1)  
		END  
		ELSE 
		BEGIN  
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'PrinterSetup',@Code
			-- end of audit trail
				
			INSERT INTO PrinterSetup(Code, Name,Printer, Path, TicketNo, PrintTicket, AlternativePrinter,Active,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)
			VALUES(@Code, @Name,@Printer, @Path, @TicketNo, @PrintTicket, @AlternativePrinter,@Active,@PropertyId,0,@UserId,GETDATE())
			
			-- audit trail				
			SET @Remark = 'Printer setup '+@Code+', '+@Name+' created.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'PrinterSetup',@Code,@UserId,'I',@Remark
			-- end of audit trail	
		END    
	END  

	ELSE IF @Operation ='U'  
	BEGIN     
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'PrinterSetup',@Code
		-- end of audit trail
					
		UPDATE PrinterSetup  
		SET    
		Code= @Code,
		Printer = @Printer,
		Name=@Name,
		Path=@Path,
		TicketNo=@TicketNo,
		PrintTicket=@PrintTicket,
		AlternativePrinter=@AlternativePrinter ,
		Active=@Active,
		PropertyId=@PropertyId,
		UpdatedUserId=@UserId,
		UpdatedDateTime=GETDATE(),
		IsUpload=0
		WHERE Code= @Code --and 	Name=@Name

		-- audit trail				
		SET @Remark = 'Printer setup '+@Code+', '+@Name+' updated.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'PrinterSetup',@Code,@UserId,'U',@Remark
		-- end of audit trail	
	END     
END

GO

