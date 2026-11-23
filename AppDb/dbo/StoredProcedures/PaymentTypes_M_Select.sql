
-- =============================================
-- Author:		Chiraj
-- Create date: 2018-07-23
-- Description:	Select Payment Types
-- =============================================
--[dbo].[PaymentTypes_M_Select]2,2
CREATE  PROCEDURE [dbo].[PaymentTypes_M_Select] --2, 2
@Active INT = 2,
@PropertyId INT
AS
BEGIN	

	--	RAISERROR('Category Prefix already exists',16,1)  

	SET NOCOUNT ON;

	SELECT 
		T.Id,
		T.PayCode
		,T.Description
		,T.Cash
       ,T.CreditCard
       ,T.NoValue
       ,T.Other
       ,T.Remarks
       ,T.DrawerOpen
       ,T.Credit     
       ,T.Active
       ,T.VOUCHER
       ,T.IsStaffMeal 
	   ,T.Frimi  
	   ,T.PropertyId
	   ,T.IsEWallet,T.IsRoomPosting,T.IsECR,
	   (
				SELECT		Outlet AS Code
				FROM		POS_OutletWisePaymentTypes 
				WHERE		[PropertyId]=T.PropertyId AND [PayCode]=T.PayCode
				FOR JSON Auto
	   )AS OutletJson,
	   IsShowOnMultiCurrency AS IsShowOnMultiCurrency
	FROM  PaymentTypes T WHERE PropertyId=@PropertyId AND (@Active = 2 OR Active = @Active) order by PayCode 

    
END

GO

