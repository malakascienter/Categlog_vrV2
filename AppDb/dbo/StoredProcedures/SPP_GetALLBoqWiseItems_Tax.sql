 
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- SPP_GetALLBoqWiseItems 8,5,72,5
-- SPP_GetALLBoqWiseItems 8,0,0,5
-- SPP_GetALLBoqWiseItems 20,0,0,14
--[dbo].[SPP_GetALLBoqWiseItems_Tax] 11,7,1
-- =============================================
CREATE PROCEDURE [dbo].[SPP_GetALLBoqWiseItems_Tax] 
	-- Add the parameters for the stored procedure here
    @TaxID INT,
	@BOQID INT,
	@IsBoq BIT
AS
    BEGIN

	CREATE TABLE #tempT
	(Id INT,
	ItemCode VARCHAR(255),
	ItemName VARCHAR(255),
	IsTaxApplied BIT,
	TaxRate DECIMAL(18,2)
	
	)

	CREATE TABLE #tempB
	(
	Id INT,
	ItemID INT,
	Rate DECIMAL(18,2)
	)

	 

	INSERT INTO #tempT
	        ( Id, ItemCode, ItemName )
        SELECT DISTINCT
				ST.Id,
				ST.StockItemCode AS ItemCode,
                ST.Name AS ItemName
				--BT.TaxId AS TaxId
				--BRD.TaxRate AS TaxRate
				--(CASE WHEN Taxid=@TaxID THEN 1 ELSE 0 END) AS IsTaxApplied
        FROM    dbo.BOQRateanalysisAllocationDetails AS BRD INNER JOIN  dbo.StockItemHeaders ST ON BRD.ItemID=st.Id  WHERE BRD.BOQID=@BOQID
		INSERT INTO #tempB
		        ( Id, ItemID,Rate )
		
		SELECT Id,ItemId,TaxRate FROM dbo.BoqTaxes WHERE TaxId=@TaxID AND BoqId=@BOQID AND IsBoq =@IsBoq

		
		

		DECLARE @Id INT,@ItemID INT,@Rate DECIMAL(18,2)
		WHILE((SELECT COUNT(Id) FROM #tempB)>0)
		BEGIN

		SELECT TOP(1)@Id=Id,@ItemID=ItemID,@Rate=Rate FROM #tempB

		UPDATE #tempT SET IsTaxApplied=1,TaxRate=@Rate WHERE Id=@ItemID

		DELETE FROM #tempB WHERE Id =@Id
		END

		SELECT * FROM #tempT
		
     END

GO

