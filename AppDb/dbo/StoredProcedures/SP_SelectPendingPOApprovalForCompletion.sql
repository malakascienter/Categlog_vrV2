-- =============================================
-- Author				: Nivesh
-- Create date			: 2025-03-24
-- Last Modified By		: Nivesh
-- Last Modified Date	: 2025-11-18
-- Description:	Get pending PO for completion
-- =============================================
-- SP_SelectPendingPOApprovalForCompletion 'C',1,'2025-03-24', '2025-03-31'

CREATE PROCEDURE [dbo].[SP_SelectPendingPOApprovalForCompletion]
	@Type				VARCHAR(2) = 'C',
	@PropertyID			INT = 0,
	@FromDate			DATE = NULL,
	@ToDate				DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @FromDate IS NULL OR @FromDate =''
		SET @FromDate = GETDATE()

	IF @ToDate IS NULL OR @ToDate = ''
		SET @ToDate = GETDATE()
	DECLARE @IsCentralLogin BIT
		
		SELECT	TOP (1) @IsCentralLogin = IsCentralLogin FROM Companies
		WHERE CompanyID =  CASE WHEN @PropertyID = -999 THEN CompanyID ELSE @PropertyID END

		IF(@IsCentralLogin = 1)
		BEGIN
			SELECT DISTINCT H.ID SN,
			   S.Name AS SupplierName,
			   H.SupplierID AS SupplierId,
		       H.PoNo ,
		       U.UserName ReqUserProf,
			   l.Name Location, 
			   h.DocumentDate ,
			   H.NetTotal POValue,
				   ISNULL(H.Remarks,'') Remarks,
				   C.name CompanyName,
				D.Name AS Department,
				H.DepartmentID AS DepartmentID
			FROM dbo.PoHeaders H
			INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
			INNER JOIN [dbo].[CentralUsers] U ON u.Id = H.UserProfileID
			INNER JOIN suppliers S ON S.ID = H.SupplierID
			INNER JOIN dbo.Locations L ON L.Id = H.LocationID
			INNER JOIN Companies C ON C.CompanyID = H.PropertyID
			LEFT JOIN Departments D ON D.Id = H.DepartmentID
			WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END
			AND H.DocumentDate BETWEEN 
			CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN H.DocumentDate ELSE @FromDate END
			AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN H.DocumentDate ELSE @ToDate END
			GROUP BY H.ID, S.Name, H.SupplierID, H.PoNo, U.UserName, L.Name, H.DocumentDate, H.NetTotal, H.Remarks, C.Name, D.Name,H.DepartmentID
		--	HAVING SUM(PD.ReceivedQuantity) = 0;
		END
		ELSE
		BEGIN
			SELECT DISTINCT H.ID SN,
		       H.PoNo ,
		       U.UserName ReqUserProf,
			   l.Name Location, 
			   h.DocumentDate ,
			   H.NetTotal POValue,
			   ISNULL(H.Remarks,'') Remarks,
			   C.Name CompanyName,
			   D.Name AS Department,
				H.DepartmentID AS DepartmentID
			FROM dbo.PoHeaders H
			INNER JOIN dbo.UserMasters U ON u.Id = H.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = H.LocationID
			INNER JOIN Companies C ON C.CompanyID = H.PropertyID
			LEFT JOIN Departments D ON D.Id = H.DepartmentID
			WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND H.DocumentDate BETWEEN 
			CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN H.DocumentDate ELSE @FromDate END
			AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN H.DocumentDate ELSE @ToDate END
			AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END
		END
END

GO

