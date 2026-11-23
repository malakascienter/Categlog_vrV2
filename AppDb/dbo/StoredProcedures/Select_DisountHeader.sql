-- =============================================
-- Author:		Chiraj
-- Create date: 2020-06-4
-- Description:	Discounts_M_Select
-- =============================================
CREATE PROCEDURE [dbo].[Select_DisountHeader]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	select 
[Id], [Code], [Description], 

CONVERT(varchar(20),
[TimeFrom],100) AS [TimeFrom], 
CONVERT(varchar(20),
[TimeTo],100) AS [TimeTo],
[DateFrom], [DateTo], 
[Percentage], [IsAutoApply], 
[IsAuthorization], 
[IsDay], [SysDate], 
[ValidationMode], [DiscountType],
[IsNeedRemark], [IsValidatePayType], 
[DiscountValue], [IsActive], [CreatedUserId],
[CreatedDateTime], [UpdatedUserId], [UpdatedDateTime], 
[OutletListJson], [MenuItemJson],
[DaysJson], [IsItemWiseDiscount]
   From DiscountHeader WHERE PropertyId=@PropertyId
END

GO

