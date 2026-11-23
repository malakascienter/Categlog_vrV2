-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-01
-- Description:	Get UserWise Transaction
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_GetUserWiseTransaction] 
	@PropertyID INT,
	@LocationID VARCHAR(5),
	@TransactionID INT
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @IsDropdown BIT =0
	SET @LocationID = CASE 
						WHEN @LocationID =NULL 
						THEN '-999'
						ELSE @LocationID 
					END

	SELECT @IsDropdown = ISNULL(IsDropdown,0) 
	FROM SPO_TransactionType 
	WHERE Id = @TransactionID
    
	SELECT 
		SUA.Id ,
		L.[description] AS [LocationName],
		SUA.LocationId,
		CU.FullName,
		SUA.UserProfileId,
		SAT.Approval,
		SUA.ApproveTypeID,
		SUA.PropertyId,
		SAT.ApprovalLevel,
		SUA.TransactionTypeID
	FROM [dbo].[SPO_UserWiseApproveLevels] SUA
	LEFT JOIN Location_Ref L ON L.code = SUA.LocationId
	INNER JOIN CentralUsers CU ON CU.Id = SUA.UserProfileId
	INNER JOIN [dbo].[SPO_ApprovalType] SAT ON SAT.Id = SUA.ApproveTypeID
	WHERE SUA.PropertyId = @PropertyID
	AND SUA.TransactionTypeID = @TransactionID
	AND SUA.LocationId = CASE 
							WHEN @LocationID ='-999' AND @IsDropdown =1
							THEN SUA.LocationId
							WHEN  @LocationID <> '-999'  AND @IsDropdown =1
							THEN @LocationID
							ELSE
							SUA.LocationId
						END
	ORDER BY SUA.LocationId, SAT.ApprovalLevel
END

GO

