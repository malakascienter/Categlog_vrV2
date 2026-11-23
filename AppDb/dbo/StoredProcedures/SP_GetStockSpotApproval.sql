-- =============================================
-- Author:		Nivesh
-- Create date: 2024-10-29
-- Description:	Get Stock Spot Approval
-- =============================================
-- SP_GetStockSpotApproval 1,1,1

CREATE PROCEDURE [dbo].[SP_GetStockSpotApproval] 
	@LocationID INT,
	@PropertyID INT,
	@LevelID INT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY 
	IF(@PropertyID = NULL)
	BEGIN
		RAISERROR('Property Invalid',16,1)
		ROLLBACK TRANSACTION
	END

	IF(@LocationID = NULL)
	BEGIN
		RAISERROR('Location Invalid',16,1)
		ROLLBACK TRANSACTION
	END

	IF(@LevelID = NULL)
	BEGIN
		RAISERROR('Level Invalid',16,1)
		ROLLBACK TRANSACTION
	END

	IF(@LevelID = 1)
	BEGIN
		
		--SELECT SSH.*,L.Name LocationName ,
		--(SELECT SSSD.*,SH.Name ItemName, SH.StockItemCode FROM StockSpotCheckDetail SSSD
		--LEFT JOIN StockItemHeaders SH ON SH.ID = SSSD.StockItemID
		--WHERE SSSD.StockSpotHeaderID = SSH.ID FOR JSON PATH) AS StockSpotDetailJson
		--FROM
		--StockSpotCheckHeader SSH
		--INNER JOIN StockSpotApprovalLog SSA ON SSA.StockSpotHeaderID = SSH.ID
		--LEFT JOIN Locations L ON L.Id = SSH.LocationID
		--WHERE SSH.LocationID = @LocationID AND SSH.PropertyID = @PropertyID AND SSA.Status = 'P' AND SSA.LevelNo = @LevelID AND SSA.IsApproved =0

		SELECT SSH.ID,SSH.PropertyID,SSH.CreatedDate,SSH.DocNo,
		 FirstLevel = CASE WHEN @LevelID = 1 THEN 1 ELSE 0 END,
		 SecondLevel = CASE WHEN @LevelID = 1 THEN 0 ELSE NULL END,
		SSH.ID,SSH.IsApprove,SSH.LocationID,SSH.Remark,SSH.SpotCheckDate,SSH.UserID,L.Name LocationName ,
		(SELECT SSSD.*,SH.Name ItemName, SH.StockItemCode
		,(SSSD.PhysicalQty  - SSSD.QuantityInHand) Variance
		,CASE WHEN SSSD.PhysicalQty  - SSSD.QuantityInHand = 0 THEN 0 ELSE 1 END AS IsRemarkMandatory
		FROM StockSpotCheckDetail SSSD
		LEFT JOIN StockItemHeaders SH ON SH.ID = SSSD.StockItemID
		WHERE SSSD.StockSpotHeaderID = SSH.ID FOR JSON PATH) AS StockSpotDetailJson
		FROM
		StockSpotCheckHeader SSH
		INNER JOIN StockSpotApprovalLog SSA ON SSA.StockSpotHeaderID = SSH.ID
		LEFT JOIN Locations L ON L.Id = SSH.LocationID
		WHERE SSH.LocationID = @LocationID AND SSH.PropertyID = @PropertyID AND SSA.Status = 'P' AND SSA.LevelNo = @LevelID AND SSA.IsApproved =0

	END
	ELSE IF(@LevelID = 2)
	BEGIN
		
		--IF EXISTS(SELECT 1 
		--FROM
		--StockSpotCheckHeader SSH
		--INNER JOIN StockSpotApprovalLog SSA ON SSA.StockSpotHeaderID = SSH.ID
		--WHERE SSH.LocationID = @LocationID AND SSH.PropertyID = @PropertyID AND SSA.Status = 'C' AND SSA.LevelNo = 1 AND SSA.IsApproved =1 )
		--BEGIN

			SELECT SSH.ID,SSH.PropertyID,SSH.CreatedDate,SSH.DocNo,
		 FirstLevel = CASE WHEN @LevelID = 2 THEN 0 ELSE NULL END,
		 SecondLevel = CASE WHEN @LevelID = 2 THEN 1 ELSE 0 END,
		SSH.ID,SSH.IsApprove,SSH.LocationID,SSH.Remark,SSH.SpotCheckDate,SSH.UserID,L.Name LocationName,
			(SELECT SSSD.*,SH.Name ItemName, SH.StockItemCode
			,(SSSD.PhysicalQty  - SSSD.QuantityInHand) Variance
		,CASE WHEN SSSD.PhysicalQty  - SSSD.QuantityInHand = 0 THEN 0 ELSE 1 END AS IsRemarkMandatory
			FROM StockSpotCheckDetail SSSD
			LEFT JOIN StockItemHeaders SH ON SH.ID = SSSD.StockItemID
			WHERE SSSD.StockSpotHeaderID = SSH.ID FOR JSON PATH) AS StockSpotDetailJson 
			FROM
			StockSpotCheckHeader SSH
			INNER JOIN StockSpotApprovalLog SSA ON SSA.StockSpotHeaderID = SSH.ID
			LEFT JOIN Locations L ON L.Id = SSH.LocationID

			WHERE SSH.LocationID = @LocationID AND SSH.PropertyID = @PropertyID AND SSA.Status = 'P' AND SSA.LevelNo = @LevelID AND SSA.IsApproved =0
			AND SSA.StockSpotHeaderID NOT IN (SELECT StockSpotHeaderID FROM
			StockSpotApprovalLog 
		WHERE LocationID = @LocationID AND PropertyID = @PropertyID AND Status = 'P' AND LevelNo = 1 AND IsApproved =0
			)
		--END
		--ELSE
		--BEGIN
		--	SELECT SSH.*,NULL LocationName, NULL as StockSpotDetailJson
		--	FROM StockSpotCheckHeader SSH
		--	LEFT JOIN StockSpotApprovalLog SSA ON SSA.StockSpotHeaderID = SSH.ID
		--	WHERE 1 = 0 -- Always false to return an empty result set
		--END
	END

	END TRY
	BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

