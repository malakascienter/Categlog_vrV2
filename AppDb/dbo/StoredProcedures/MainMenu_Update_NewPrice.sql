-- ============================================================      
-- AUTHOR - BANU      
-- DATE CREATED - 17/10/2018      
-- DESCRIPTION - UPDATE NEW PRICE FOR MAIN MENU       
-- ============================================================      
      
CREATE PROCEDURE [dbo].[MainMenu_Update_NewPrice]      
(      
 @MenuId INT,      
 @MenuItemCode CHAR(4),      
 @Price MONEY,      
 @NewPrice MONEY,    
 @DeliveryPrice MONEY,    
 @NewDeliveryPrice MONEY,    
 @PackagingCharge MONEY,
 @ExecutivePrice MONEY,
 @NewExecutivePrice MONEY,
 --@CostPrice MONEY,    
 @EffectiveDate VARCHAR(10),
 @PropertyId INT,
 @UserId INT
 
)      
AS      
BEGIN       
 DECLARE @EffDate DATETIME = CONVERT(DATETIME,@EffectiveDate,103);      
 IF @EffDate = CONVERT(DATE,GETDATE())       
  BEGIN      
   UPDATE MainMenu 
   SET 
   Price = @NewPrice,
   NewPrice = @NewPrice,
   EFFECTdATE = @EffDate,
   --costprice = @CostPrice,    
	DelivaryPrice = @NewDeliveryPrice,
	NewDelivaryPrice = @NewDeliveryPrice,  
	PackingCharge = @PackagingCharge,
	ExecutivePrice=@NewExecutivePrice,
	NewExecutivePrice=@NewExecutivePrice,
	LastModifiedDateTime=GETDATE(),
	LastModifiedUserID=@UserId
   WHERE 
   Id = @MenuId AND ItemCode = @MenuItemCode 
   AND PropertyId=@PropertyId;      
  END      
 ELSE      
  BEGIN      
   UPDATE MainMenu
   SET 
   NewPrice = @NewPrice,
   NewDelivaryPrice = @NewDeliveryPrice, 
	EFFECTdATE = @EffDate, 
	NewPackagingCharge = @PackagingCharge,
	ExecutivePrice=@NewExecutivePrice,
	NewExecutivePrice=@NewExecutivePrice,
	LastModifiedDateTime=GETDATE(),
	LastModifiedUserID=@UserId
   WHERE
   Id = @MenuId AND ItemCode = @MenuItemCode AND PropertyId=@PropertyId;      
  END       
END;

GO

