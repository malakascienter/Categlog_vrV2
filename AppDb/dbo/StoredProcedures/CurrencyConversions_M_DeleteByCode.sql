
CREATE PROCEDURE [dbo].[CurrencyConversions_M_DeleteByCode]
	@Id INT,
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	-- Audit trail ----------------------------		
	EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyConversions',@Id,'POS','POSCRCD','D',0,'','','','','',@PropertyId
	-- End of Audit trail ---------------------

	DELETE FROM [dbo].POS_CurrencyConversions WHERE CompanyId = @PropertyId AND Id = @Id

	--EXEC Insert_Sync_MasterDataTransferStatus 'CurrencyRates',0,@Code,@PropertyId
   
END

GO

