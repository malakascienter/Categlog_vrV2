
CREATE FUNCTION  [dbo].[IsAdditionalChargeAddToItemCost](@AdditionalChargeID bigint)
returns bit
begin
return (select IsAddToItemCost from AdditionalChargesDetails d where d.Id=@AdditionalChargeID)
end

GO

