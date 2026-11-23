-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- [dbo].[SP_GetItemWiseSupplier]  1,59,1


-- [dbo].[SP_GetItemWiseSupplier] 1,3914,1

CREATE PROCEDURE [dbo].[SP_GetItemWiseSupplier] 
	-- Add the parameters for the stored procedure here
	
	@PropertyID INT,
	@StockItemID INT,
	@LocationID INT 

AS
BEGIN
	SELECT S.Id,PropertyID ,
          Code ,
          Name ,
          Address1 ,
          BillingAddress ,
          Email ,
          Telephone1 ,
          Telephone2 ,
          FaxNo ,
          ContactPerson ,
          CountryID ,
          Remarks ,         
          CreditPeriod ,
          PaymentTermID ,
          CurrencyID ,
          NameOnCheque ,
          SupplierGradingID ,
          I.IsDefaultSupplier ,
          s.IsActive ,
         I. IPAddress ,
          I.CreatedUserID ,
         I. LastModUserID ,
         I. CreatedDate ,
          I.LastModDate ,
          IsLabor,I.CostPrice AS CreditLimit 
		  ,ISNULL(I.IsContractedSupplier,0) IsContractedSupplier
         ,ROUND(ISNULL([dbo].[FN_GetLastGRNPrice_SupplierWise](@LocationID, @StockItemId, S.ID), 0), 2) AS LastGRNPrice
		  FROM dbo.Suppliers s 
INNER JOIN dbo.SupplierWiseItemDetails i ON i.SupplierID = s.ID AND i.CompanyId = @PropertyID
--WHERE s.PropertyID = @PropertyID AND i.StockItemID = @StockItemID AND i.LocationId=@LocationID
WHERE i.StockItemID = @StockItemID AND i.LocationId=@LocationID
ORDER BY s.NAME asc


END

GO

