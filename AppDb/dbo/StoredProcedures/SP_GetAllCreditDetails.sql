
--SP_GetAllCreditDetails 476
CREATE PROCEDURE SP_GetAllCreditDetails
(
@CustomerID INT 
)
AS
BEGIN

	SELECT * FROM dbo.CreditApprovals WHERE DocumentStatus='P' AND IsApproved=1 AND CustomerId=@CustomerID
END

GO

