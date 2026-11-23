
-- =============================================  
-- Author:  Banu  
-- Create date: 29/10/2018  
-- Description: Select All Tax Group Rows  
-- =============================================  
CREATE PROCEDURE [dbo].[TaxType_M_Select]--  1 ,1 
@isActive INT=2,
@PropertyId INT
AS  
BEGIN   
 SET NOCOUNT OFF;  


 IF EXISTS( SELECT * FROM Companies WHERE IsFiscalEnable = 1 AND CompanyID = @PropertyId )
BEGIN

	SELECT * 
	FROM Gen_ChargeType WHERE  PropertyId=@PropertyId  AND (@IsActive=2 OR isActive=@isActive) AND ChargeTypeID NOT IN (SELECT ServiceChargeId FROM Companies WHERE CompanyID = @PropertyId)

END
ELSE
BEGIN

	SELECT * 
	FROM Gen_ChargeType WHERE  PropertyId=@PropertyId  AND (@IsActive=2 OR isActive=@isActive)

END


 
END

GO

