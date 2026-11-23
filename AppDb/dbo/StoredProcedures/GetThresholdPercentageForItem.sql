CREATE PROCEDURE [dbo].[GetThresholdPercentageForItem] 

	@StockItemHeaderID INT,
	@PropertyID INT
	AS 
	BEGIN

	DECLARE @Threshold VARCHAR(150), @ThresholdValueAttId INT

	SELECT @ThresholdValueAttId = ThresholdValueAttributeId  FROM CompanySettings WHERE CompanyId = @PropertyID

	IF EXISTS (SELECT 1 FROM StockItemWiseAttributes WHERE StockItemHeaderID = @StockItemHeaderID AND StockItemAttributeID = @ThresholdValueAttId )
		BEGIN
			SELECT @Threshold = Remarks FROM StockItemWiseAttributes WHERE StockItemHeaderID = @StockItemHeaderID AND StockItemAttributeID = @ThresholdValueAttId
			IF @Threshold <> ''
				BEGIN
					SELECT Remarks AS ThresholdPercentage FROM dbo.StockItemWiseAttributes
					WHERE StockItemAttributeID = @ThresholdValueAttId AND StockItemHeaderID = @StockItemHeaderID
				END
			ELSE
				 SELECT 0 ThresholdPercentage
				
		END
	ELSE
	    BEGIN
				 SELECT 0 ThresholdPercentage
		END


	END

GO

