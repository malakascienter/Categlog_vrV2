

CREATE  PROCEDURE [dbo].[ItemWastage_M_Select]  --1
	@PropertyId INT,
	@BusinessDate DATETIME
AS  
BEGIN  
	
	SELECT I.[Id]
      ,I.[DocNo]
      ,I.[Outlet]
	  ,( SELECT description FROM Location_Ref L WHERE L.[PropertyId] = @PropertyId AND L.code = I.[Outlet]) AS OutletName
      ,I.[BusinessDate]
      ,I.[Qty]
      ,I.[ItemCode]
	  ,( SELECT Description FROM MainMenu M WHERE M.[PropertyId] = @PropertyId AND M.[ItemCode] = I.ItemCode) AS ItemName
      ,I.[Remark]
      ,I.[PropertyId]
      ,I.[CreatedUserId]
      ,I.[CreatedDateTime]
      ,I.[ModifiedUserId]
      ,I.[ModifiedDateTime]
	  ,I.[Price]
	  ,W.Name AS WastageType,
	  W.Id AS WastageTypeId
  FROM [dbo].[POS_ItemWastageDetails] I
  LEFT JOIN [ItemWastageType] W ON I.WastageTypeId = W.Id
  WHERE I.[BusinessDate] = @BusinessDate AND I.[PropertyId] = @PropertyId

END

GO

