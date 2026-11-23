
CREATE PROCEDURE  UpdateDepartmentWiseCostProvision @COSTID INT,@Cost Decimal
as 
begin

	update DepartmentWiseCostProvisions set BalanceCost=BalanceCost +@Cost where ID=@COSTID

end

GO

