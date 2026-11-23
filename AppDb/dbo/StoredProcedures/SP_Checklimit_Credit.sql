

--SP_Checklimit_Credit 483,222,-1
CREATE PROCEDURE SP_Checklimit_Credit @customerID INT, @Amount DECIMAL,@result INT OUTPUT

AS
BEGIN
DECLARE @TotalAmount DECIMAL,@limit DECIMAL

SELECT @TotalAmount=SUM(Amount) FROM dbo.CreditApprovals GROUP BY CustomerId HAVING CustomerId=  @customerID 


SELECT @limit=CreditLimit FROM dbo.Customers WHERE Id=@customerID

IF (@TotalAmount+@Amount>@limit) 

BEGIN
SET @result=0

END
ELSE

BEGIN
SET @result=1

END


SELECT 'Total Amount',@TotalAmount

SELECT 'limit',@limit

SELECT 'Amount',@Amount

SELECT @result

END



--UPDATE dbo.Customers SET CreditLimit= 5344239401 WHERE Id=476


--SELECT * FROM dbo.CreditApprovals

GO

