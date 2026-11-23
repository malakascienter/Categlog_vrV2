
CREATE PROCEDURE [dbo].[POS_KioskMenuCategory_M_Select]  
@IsActive       INT = 2 ,
@PropertyId		INT = 1
AS  
BEGIN   
 SET NOCOUNT ON;  


 --SELECT * ,'' AS ItemTypeName
 --FROM POS_KioskMenuCategory UR  
  
 --SELECT * ,T.Name AS ItemTypeName
	--  FROM POS_KioskMenuCategory UR  INNER JOIN POS_Image IM ON UR.CategoryID = IM.Code
	--  INNER JOIN POSItemTypes T ON UR.ItemType = T.Code
 --WHERE (@IsActive = 2 OR @IsActive = UR.IsActive)  AND IM.DataType = 'CAT' AND T.PropertyId = @PropertyId
 --ORDER BY SortOrder ASC


 SELECT * ,T.Name AS ItemTypeName
	  FROM POS_KioskMenuCategory UR  
	  INNER JOIN POS_Image IM ON UR.CategoryID = IM.Code
	  INNER JOIN POSItemTypes T ON UR.ItemType = T.Code
 WHERE (@IsActive = 2 OR @IsActive = UR.IsActive)  AND IM.DataType = 'CAT' AND T.PropertyId = @PropertyId
 ORDER BY SortOrder ASC
  
END

GO

