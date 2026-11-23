--[dbo].[SP_Search_GetAttributesForItem] 2128
--go
CREATE PROCEDURE [dbo].[SP_Search_GetAttributesForItem]

	@value INT
	AS 
	BEGIN

			IF EXISTS (SELECT 1 FROM StockItemWiseAttributes WHERE StockItemHeaderID = @value)
				BEGIN
						--SELECT SA.*,
						--ISNULL(IWA.Remarks,'') remarks,ISNULL(IWA.IsActive,0) active
						--FROM            
						--StockItemWiseAttributes IWA
						--INNER JOIN StockItemAttributes SA ON SA.Id = IWA.StockItemAttributeID
						--WHERE IWA.StockItemHeaderID = @value
						CREATE TABLE #TempAtt(Id INT , Code VARCHAR(200), Name VARCHAR(200),IsRemarksApplicable BIT ,
						IPAddress VARCHAR(200),CreatedUserID INT ,LastModUserID INT , CreatedDate DATE, LastModDate DATE ,
						remarks VARCHAR(250), active BIT )
					
						INSERT INTO #TempAtt SELECT *,'' remarks,0 active FROM StockItemAttributes

						UPDATE T
						SET T.remarks = ISNULL(IWA.Remarks,''), T.active = ISNULL(IWA.IsActive,0)
						FROM #TempAtt T
						INNER JOIN StockItemWiseAttributes IWA
						ON T.Id = IWA.StockItemAttributeID
						WHERE IWA.StockItemHeaderID = @value

						SELECT * FROM #TempAtt
	

				END
			ELSE
				BEGIN
						SELECT *,'' remarks,0 active
						FROM  StockItemAttributes
			END




	END

GO

