CREATE PROCEDURE [dbo].[SP_Get_TransactionTypes_For_All](
@IsApprove BIT =0
)
AS
BEGIN

	IF(ISNULL(@IsApprove,0) = 1)
	BEGIN

		SELECT Id,CONCAT(Code,'/',Name) AS TransactionType FROM dbo.TransactionTypes WHERE  IsActive = 1  AND ID not in(5,6,12)
	
	END
	ELSE
	BEGIN
		
		SELECT Id,CONCAT(Code,'/',Name) AS TransactionType FROM dbo.TransactionTypes WHERE  IsActive = 1 

	END

END

GO

