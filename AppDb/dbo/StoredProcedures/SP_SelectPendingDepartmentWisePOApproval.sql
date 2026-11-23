-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-17
-- Description:	Get Department-wise PO Approvals
-- =============================================
CREATE     PROCEDURE [dbo].[SP_SelectPendingDepartmentWisePOApproval] 
(	@Type				VARCHAR(2) = 'S',
	@UserProfileId		INT = 1,
	@PropertyID			INT = 0,
	@PoHeaderID			VARCHAR(100) = NULL,
	@PoDetailID			VARCHAR(100) = NULL
)
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @IsPoModificationComponent BIT = 0,
	@IsCentralLogin BIT =0
	
	CREATE TABLE #PENINGPOHEADER (
		POHeaderID INT ,
		ApprovalTypeID INT,
		ReqUserProfId INT,
		ReqUserProf VARCHAR(MAX),
		POValue DECIMAL(18,2),
		TransactionID INT
	)

	(SELECT 
		@IsPoModificationComponent= IsPoModificationComponent,
		@IsCentralLogin = IScentrallogin
	FROM Companies 
	WHERE CompanyID = @PropertyID) 
		-------------------------------------------
	SELECT 
		ta.PropertyID,
		ta.LocationID,
		ta.TransactionID ,
		ua.UserProfileID,
		ta.SeqID,
		tt.Name AS 'TransationTypeName',
		ld.Name 'Location',
		tt.Code AS 'Code' ,
		ta.ApprovalTypeID 
	INTO #TempTable 
	FROM dbo.UserWiseApproveLevels ua
	INNER JOIN dbo.TransactionWiseApprovalTypes ta 
	ON ua.approvelevelID =ta.ApprovalTypeID AND
		ua.locationID=ta.locationID AND 
		ua.propertyID=ta.PropertyID
		----------Added-----------------
		AND ua.TransactionTypeID = ta.TransactionID
		----------Added-----------------
	INNER JOIN dbo.TransactionTypes tt ON tt.Id = ta.TransactionID
	INNER JOIN dbo.Departments ld ON ld.Id = ta.LocationID
	WHERE ua.userprofileID= @UserProfileId  
	AND ua.PropertyID = CASE 
							WHEN @PropertyID = -999 
							THEN ua.PropertyId 
							ELSE @PropertyID 
						END 
	AND tt.Id =2 -- added by Nivesh 2024 02 08
	-------------------------------------------------------
	INSERT INTO #PENINGPOHEADER
	SELECT DISTINCT 
		req.Id,					
		UserToApprove.ApprovalTypeID,
		req.UserProfileID AS 'ReqUserProfId',
		up.UserName AS 'ReqUserProf',
		(
		SELECT 
		SUM(ISNULL(RequestedQuantity,0) *
		(ISNULL(UnitPrice,0) -
		CASE 
			WHEN DiscountValue > 0 
			THEN DiscountValue 
			ELSE (UnitPrice *DiscountPercentage /100) 
		END)) 
		FROM dbo.PoDetails 
		WHERE PoHeaderID = req.Id) AS 'POValue',
		al.TransactionID
	FROM dbo.ApprovalLogs al 
	INNER JOIN
	#TempTable UserToApprove ON al.PropertyID=UserToApprove.PropertyID
	INNER JOIN dbo.PoHeaders req ON  req.Id = al.TransactionHeaderID AND UserToApprove.PropertyID = UserToApprove.PropertyID  
		AND al.LocationID=UserToApprove.LocationID 
		AND al.TransactionID = UserToApprove.TransactionID 
		AND IsComplete=0 
		AND UserToApprove.SeqID = al.SeqID 
	INNER JOIN [dbo].[CentralUsers] up ON up.Id = req.UserProfileID
	WHERE al.SeqID  IN (
		SELECT MIN(seqID) 
		FROM dbo.ApprovalLogs 
		WHERE IsComplete = 0 
		AND PropertyID =CASE 
							WHEN @PropertyID = -999 
							THEN PropertyID 
							ELSE @PropertyID 
						END
		--AND LocationID =@LocationID 
		AND dbo.ApprovalLogs.TransactionID =2
		AND TransactionHeaderID=al.TransactionHeaderID 
	) 

	IF(@Type = 'S')
	BEGIN
		IF (@IsPoModificationComponent  = 0 )
		BEGIN
			SELECT     
			h.Id SN,
			app.Id AS ApprovalTypeID,
			app.ApprovalTypeName [Approvel], 
			l.Name Location,
			#PENINGPOHEADER.ReqUserProfId,
			#PENINGPOHEADER.ReqUserProf,
			#PENINGPOHEADER.POValue,
			PoNo, 
			DocumentDate,
			s.Name Supplier, 
			h.Remarks,
			#PENINGPOHEADER.TransactionID,
			app.ApprovalTypename,
			[dbo].[GET_LastApprovedUser](2,h.Id) AS LastApprovedUser,
			C.Name AS CompanyName,
			h.TaxTotal,
			apl.seqid as SeqID,
			CASE 
            WHEN apl.seqid = 1 
			--and h.IsDirectPo = 0
			and C.isPOPrepModification = 1  THEN 1
            ELSE 0
        END as SeqIDStatus,
		D.Name Department,
			apl.LocationID DepartmentID,
		(SELECT ph.PoNo,rh.DocumentNo AS PRNo,pwp.PoWisePRID,pwp.PoHeaderID,pwp.RequestHeaderID,pwp.StockItemID FROM 
			PoWisePRs pwp 
			INNER JOIN PoHeaders ph
			ON ph.Id = pwp.PoHeaderID
			INNER JOIN RequestHeaders rh
			ON rh.Id = pwp.RequestHeaderID
			WHERE ph.Id = h.Id  FOR JSON PATH  ) AS PRDetailJson
		FROM         dbo.PoHeaders h
		INNER JOIN  #PENINGPOHEADER on #PENINGPOHEADER.POHeaderID = h.Id
		INNER JOIN dbo.Locations l on l.Id=h.locationId
		INNER JOIN dbo.Suppliers s on h.SupplierID=s.ID 
		INNER JOIN dbo.ApprovalTypes app on app.Id= #PENINGPOHEADER.ApprovalTypeID
		INNER JOIN dbo.ApprovalLogs apl on apl.TransactionHeaderID = h.Id and apl.ApprovalUserID = @UserProfileId and apl.TransactionID = 2 
		INNER JOIN Companies C on C.CompanyID = h.PropertyID
		LEFT JOIN Departments D ON D.Id = apl.LocationID
		WHERE     
			(h.PropertyID = CASE 
								WHEN @PropertyID = -999 
								THEN h.PropertyID 
								ELSE @PropertyID 
							END
			) 
			AND h.IsApproved=0 
			AND DocumentStatus <> 'X' 
		ORDER BY h.createddate DESC 
		
		END


		IF (@IsPoModificationComponent  = 1 )
		BEGIN
			SELECT  
			h.Id SN,
			app.Id AS ApprovalTypeID,
			app.ApprovalTypeName [Approvel], 
			l.Name Location,
			#PENINGPOHEADER.ReqUserProfId,
			#PENINGPOHEADER.ReqUserProf,
			#PENINGPOHEADER.POValue,
			PoNo, 
			DocumentDate,
			s.Name Supplier, 
			h.Remarks,
			#PENINGPOHEADER.TransactionID,
			app.ApprovalTypename,
			[dbo].[GET_LastApprovedUser](2,h.Id) AS LastApprovedUser,
			C.Name AS CompanyName,
			h.TaxTotal,
			apl.seqid AS SeqID,
			CASE 
				WHEN apl.seqid = 1 
				--and h.IsDirectPo = 0
				AND C.isPOPrepModification = 1  
				THEN 1
				ELSE 0
			END AS SeqIDStatus,
			D.Name Department,
			apl.LocationID DepartmentID,
			(
				SELECT 
					ph.PoNo,rh.DocumentNo AS PRNo,
					pwp.PoWisePRID,
					pwp.PoHeaderID,
					pwp.RequestHeaderID,
					pwp.StockItemID 
				FROM 
				PoWisePRs pwp 
				INNER JOIN PoHeaders ph
				ON ph.Id = pwp.PoHeaderID
				INNER JOIN RequestHeaders rh
				ON rh.Id = pwp.RequestHeaderID
				WHERE ph.Id = h.Id  FOR JSON PATH  
			) AS PRDetailJson
		FROM         dbo.PoHeaders h
		INNER JOIN  #PENINGPOHEADER ON #PENINGPOHEADER.POHeaderID = h.Id
		INNER JOIN dbo.Locations l ON l.Id=h.locationId
		INNER JOIN dbo.Suppliers s ON h.SupplierID=s.ID 
		INNER JOIN dbo.ApprovalTypes app ON app.Id= #PENINGPOHEADER.ApprovalTypeID
		INNER JOIN dbo.ApprovalLogs apl ON apl.TransactionHeaderID = h.Id 
			AND apl.ApprovalUserID = @UserProfileId 
			AND apl.TransactionID = 2 
		INNER JOIN Companies C ON C.CompanyID = h.PropertyID
		LEFT JOIN Departments D ON D.Id = apl.LocationID
		WHERE (
			h.PropertyID =	CASE 
								WHEN @PropertyID = -999 
								THEN h.PropertyID 
								ELSE @PropertyID 
							END) 
			AND h.IsApproved=0 
			AND DocumentStatus <> 'X'  
			AND h.isModificationComplete = 1
		ORDER BY h.createddate DESC 
		
		END
	END
	ELSE IF (@Type = 'X')
	BEGIN
		IF(@IsCentralLogin = 1)
		BEGIN
			SELECT DISTINCT 
				H.ID SN,
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
			AND H.PropertyID =	CASE 
									WHEN @PropertyID = -999 
									THEN H.PropertyID 
									ELSE @PropertyID 
								END
			GROUP BY 
				H.ID,
				S.Name,
				H.SupplierID,
				H.PoNo,
				U.UserName,
				L.Name,
				H.DocumentDate,
				H.NetTotal,
				H.Remarks,
				C.Name,
				D.Name,
				H.DepartmentID
			HAVING SUM(PD.ReceivedQuantity) = 0;
		END
		ELSE
		BEGIN
			SELECT DISTINCT 
				H.ID SN,
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
			WHERE DocumentStatus <> 'C' 
				AND DocumentStatus <> 'X' 
				AND H.PropertyID =	CASE 
										WHEN @PropertyID = -999 
										THEN H.PropertyID 
										ELSE @PropertyID 
									END
		END

	END
END

GO

