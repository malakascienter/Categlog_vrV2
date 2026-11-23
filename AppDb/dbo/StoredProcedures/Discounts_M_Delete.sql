

-- =============================================
-- Author:		Chiraj
-- Create date: 2020-06-04
-- Description:	delete discount
-- =============================================
CREATE PROCEDURE [dbo].[Discounts_M_Delete]
@Id INT,
@UserId INT=0,
@PropertyId INT
AS
BEGIN
BEGIN TRY
		DECLARE @Remark NVARCHAR(250)	
		IF EXISTS(SELECT * FROM DiscountHeader WHERE Id = @Id AND PropertyId=@PropertyId)
			BEGIN
			-- audit trail	 
				--		EXEC [dbo].[AuditTrail_InsertToHistory] 'Discount',@Id
					-- end of audit trail
				
				--IF EXISTS(SELECT 1 FROM Discount where IsItemWiseDiscount=1  AND id=@Id)
				--BEGIN
				--	DELETE FROM ItemWiseDiscount WHERE DiscountId=@Id
				--END	

				-- Audit trail ----------------------------		
				EXEC HotelResWeb_AuditTail_WriteToLog 'DiscountHeader',@Id,'POS','POSDHD','D',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------

				DELETE FROM DiscountHeader 
				WHERE Id = @Id AND @PropertyId=PropertyId

				DELETE FROM DiscountDetails WHERE Code=(SELECT code from DiscountHeader where PropertyId=@PropertyId AND Id=@Id) AND PropertyId=@PropertyId
				DELETE FROM DiscountDays WHERE Code=(SELECT code from DiscountHeader where PropertyId=@PropertyId AND Id=@Id) AND PropertyId=@PropertyId
				
				
				-- audit trail				
						--SET @Remark = 'Discount '+''+' deleted.';
						--EXEC [dbo].[AuditTrail_InsertTableChanges] 'Discount',@Id,@UserId,'D',@Remark
						-- end of audit trail	
			END

			ELSE
			BEGIN
				RAISERROR('Discount not exists',16,1)
			END
END TRY
	BEGIN CATCH	
		DECLARE @Error NVARCHAR(MAX)
		SET @Error=ERROR_MESSAGE()
		RAISERROR(@Error,16,1)	
	END CATCH
    
END

GO

