-- =============================================
-- Author:		Tharuka Sachinta
-- Create date: 2026-05-20
-- Description:	get departments that have bsp code 

-- [dbo].[SP_Franchise_UserWiseDepartment] 4168,1


-- =============================================
CREATE   PROCEDURE [dbo].[SP_Franchise_UserWiseDepartment]
	@userID INT,
	@comanyid INT

AS
BEGIN
	SELECT LO.Id AS LocationID,LO.Name,LO.DepartmentID 
	FROM LOCATIONS LO 
	INNER JOIN DEPARTMENTS DP ON LO.DepartmentID = DP.ID
	INNER JOIN UserWise_Location UL ON UL.LocationID = LO.ID
	WHERE UL.UserID = @userID
	AND DP.CustomerBSPCode IS NOT NULL


END

GO

