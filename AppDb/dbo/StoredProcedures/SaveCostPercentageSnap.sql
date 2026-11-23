Create procedure [dbo].[SaveCostPercentageSnap] @Id INT, @Percentage Decimal
as
Begin

update [dbo].[CostProvisionSnapShot] set Percentage = @Percentage where Id= @Id

End

GO

