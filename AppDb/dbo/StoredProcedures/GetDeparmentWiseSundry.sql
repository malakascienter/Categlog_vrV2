 -- [dbo].[GetDeparmentWiseSundry] 95,1,"-1"
CREATE Procedure [dbo].[GetDeparmentWiseSundry]
@BOQId INT,@DepartmentId INT,@OutputSundry Decimal(18,2) OUTPUT
As
BEGIN

	if EXISTS( select * from SundryRegistries where BOQID=@BOQId and DepId=@DepartmentId )
	BEGIN
	select @OutputSundry=Sum(BalanceAmount) from SundryRegistries Where BOQId=@BOQId and DepId=@DepartmentId
    Group by BOQId,DepId
	END
	ELSE
	BEGIN

	Set @OutputSundry =0

	END



END

GO

