CREATE procedure [dbo].[SaveCostPercentage] @Id INT, @Percentage Decimal
as
Begin

update costprovisions set Percentage = @Percentage where Id= @Id



End

GO

