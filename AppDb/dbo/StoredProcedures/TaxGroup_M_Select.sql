


-- =============================================  
-- Author:  Banu  
-- Create date: 29/10/2018  
-- Description: Select All Tax Group Rows  
-- =============================================  
CREATE PROCEDURE [dbo].[TaxGroup_M_Select]  --1,2
@isActive INT=2,
@PropertyId INT
AS  
BEGIN   
 SET NOCOUNT OFF;  
 SELECT CGH.* ,
 (
	SELECT 
	ChargeDetailID, 
	TD.ChargeHeaderID, 
	TD.ChargeTypeID, 
	ActualPercentage, 
	ChargeTypeSequence, 
	TD.IsActive, 
	TR.FiscalNo
	--GTY.Name as 'ChargeHeaderName', 
	--TR.Name 'ChargeTypeName'
	FROM  [dbo].[Gen_ChargeGroupDetail] AS TD
	INNER JOIN Gen_ChargeType AS GTY ON GTY.ChargeTypeID = TD.ChargeTypeID
	INNER JOIN Gen_ChargeGroupHeader AS TR ON TR.ChargeHeaderID = TD.ChargeHeaderID 
	where TD.ChargeHeaderID=CGH.ChargeHeaderID and TD.PropertyId=@PropertyId for json auto)AS TaxGroupWiseDetailsJson
 FROM [dbo].[Gen_ChargeGroupHeader] AS CGH 
  WHERE  CGH.PropertyId=@PropertyId AND (@IsActive=2 OR CGH.IsActive=@isActive )
 Order by  ISNULL(UpdatedDateTime,CreatedDateTime) DESC

END

GO

