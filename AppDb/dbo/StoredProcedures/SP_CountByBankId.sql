--SP_CountByBankId 11,2,0
CREATE PROCEDURE [dbo].[SP_CountByBankId]
   @headerid INT,
   @operation INT,
   @count INT OUTPUT

AS

	BEGIN

		IF @operation = 1
		 BEGIN
			 SELECT COUNT(ID)
			 FROM dbo.InvoiceWiseChequeDetails AS IC
			 WHERE IC.BankId = @headerid
		 END

		ELSE IF @operation = 2
			 BEGIN
				 SELECT COUNT(ID) 
				 FROM dbo.InvoiceWiseChequeDetails AS IC
				 WHERE IC.BranchId = @headerid
			 END
	END

GO

