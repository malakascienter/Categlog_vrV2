
CREATE PROCEDURE [dbo].[Currency_M_DeleteByCode]
	@Code VARCHAR(3),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @Id INT	
	SELECT @Id = Id FROM POS_CurrencyRates  WHERE [CurrCode] = @Code AND PropertyId = @PropertyId 
	-- Audit trail ----------------------------		
	EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyRates',@Id,'POS','POSCRD','D',0,'','','','','',@PropertyId
	-- End of Audit trail ---------------------

	DELETE FROM [dbo].[POS_CurrencyRates] WHERE PropertyId = @PropertyId AND CurrCode = @Code

	EXEC Insert_Sync_MasterDataTransferStatus 'CurrencyRates',0,@Code,@PropertyId
   
END

GO

