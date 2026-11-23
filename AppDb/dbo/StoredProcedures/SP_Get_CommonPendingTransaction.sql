-- =============================================
-- Author:		Nivesh
-- Create date: 2025-03-25
-- Description:	Get pending transactions 
-- =============================================
-- exec SP_Get_CommonPendingTransaction '2025-12-08', '2025-12-10',1,4168,78,8,8,1

CREATE PROCEDURE [dbo].[SP_Get_CommonPendingTransaction]
	@FromDate VARCHAR(20) = '',
	@ToDate VARCHAR(20) = '',
	@CompanyId INT = NULL,
	@UserProfileId INT = NULL,
	@TransactionID INT = NULL,
	@LocationID INT = NULL,
	@DepartmentID INT = NULL,
	@TransactionStatusID INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

BEGIN TRY 
    -- Insert statements for procedure here
	DECLARE @IsCentralLogin BIT
	
	IF @FromDate IS NULL OR @FromDate =''
		SET @FromDate = NULL

	IF @ToDate IS NULL OR @ToDate = ''
		SET @ToDate = NULL
	
	SELECT	TOP (1) @IsCentralLogin = IsCentralLogin FROM Companies
	WHERE CompanyID =  CASE WHEN @CompanyId = -999 THEN CompanyID ELSE @CompanyId END
	
	CREATE TABLE #TempUserTable (Id INT, UserName NVARCHAR(250), IsActive BIT , CreatedUserId INT, Password NVARCHAR(300),
	FirstName NVARCHAR(300), LastName NVARCHAR(300))


	IF(@IsCentralLogin  = 1)
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId, Password, FullName, ''
		FROM [dbo].[CentralUsers]

		
	END	
	ELSE
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId , Password, FirstName, LastName
		FROM UserMasters
	END


	IF OBJECT_ID('tempdb..#PENINGPOHEADER') IS NOT NULL
	DROP TABLE #PENINGPOHEADER

	create table #PENINGPOHEADER (TransactionHeaderID int ,ApprovalTypeID int,ReqUserProfId int, ReqUserProf varchar(max),POValue DECIMAL(18,2), TransactionID INT)

	DECLARE @IsCentralLogn BIT
	SELECT @IsCentralLogn = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @CompanyId = -999 THEN CompanyID  ELSE @CompanyId END

	CREATE TABLE #TempApprovalData(Id INT, UserName NVARCHAR(3000))
	IF(@IsCentralLogn = 1)
	BEGIN
		INSERT INTO #TempApprovalData
		SELECT Id,Username 
		FROM [dbo].[CentralUsers]
	END
	ELSE 
	BEGIN
		INSERT INTO #TempApprovalData
		SELECT Id,Username 
		FROM UserMasters
	END

	IF @TransactionID = 0 OR @TransactionID IS NULL
	BEGIN
		RAISERROR('Please select transaction ',16,1)
	END

	IF(@TransactionStatusID = 1) --Completion
	BEGIN
		IF(@TransactionID = 2) -- Purchase Order
		BEGIN
			IF(@IsCentralLogin = 1)
			BEGIN
				SELECT DISTINCT H.ID TransactionHeaderID,
					S.Name AS SupplierName,
					H.SupplierID AS SupplierId,
					H.PoNo DocNo,
					U.UserName ReqUserProf,
					l.Name Location, 
					FORMAT(h.DocumentDate,'yyyy-MM-dd') DocumentDate,
					H.NetTotal POValue,
					ISNULL(H.Remarks,'') Remarks,
					C.name CompanyName
				FROM dbo.PoHeaders H
				INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
				INNER JOIN #TempUserTable U ON u.Id = H.UserProfileID
				INNER JOIN suppliers S ON S.ID = H.SupplierID
				INNER JOIN dbo.Locations L ON L.Id = H.LocationID
				INNER JOIN Companies C ON C.CompanyID = H.PropertyID
				WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X'
				AND H.PropertyID = CASE WHEN @CompanyId = -999 THEN H.PropertyID ELSE @CompanyId END
				AND H.DocumentDate BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN H.DocumentDate ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN H.DocumentDate ELSE @ToDate END
				AND H.LocationID = CASE WHEN @LocationID IS NULL OR @LocationID =0 THEN H.LocationID ELSE @LocationID END
				GROUP BY H.ID, S.Name, H.SupplierID, H.PoNo, U.UserName, L.Name, H.DocumentDate, H.NetTotal, H.Remarks, C.Name
				--HAVING SUM(PD.ReceivedQuantity) = 0;
			END
			ELSE
			BEGIN
				SELECT DISTINCT H.ID TransactionHeaderID,
					S.Name AS SupplierName,
					H.SupplierID AS SupplierId,
					H.PoNo DocNo,
					U.UserName ReqUserProf,
					l.Name Location, 
					FORMAT(h.DocumentDate,'yyyy-MM-dd') DocumentDate,
					H.NetTotal POValue,
					ISNULL(H.Remarks,'') Remarks,
					C.Name CompanyName
				FROM dbo.PoHeaders H
				INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
				INNER JOIN #TempUserTable U ON u.Id = H.UserProfileID
				INNER JOIN suppliers S ON S.ID = H.SupplierID
				INNER JOIN dbo.Locations L ON L.Id = H.LocationID
				INNER JOIN Companies C ON C.CompanyID = H.PropertyID
				WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
				AND H.DocumentDate BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN H.DocumentDate ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN H.DocumentDate ELSE @ToDate END
				AND H.LocationID = CASE WHEN @LocationID IS NULL OR @LocationID =0 THEN H.LocationID ELSE @LocationID END
				AND H.PropertyID = CASE WHEN @CompanyId = -999 THEN H.PropertyID ELSE @CompanyId END
				GROUP BY H.ID, S.Name, H.SupplierID, H.PoNo, U.UserName, L.Name, H.DocumentDate, H.NetTotal, H.Remarks, C.Name
				--HAVING SUM(PD.ReceivedQuantity) = 0;
			END	
		END
		ELSE IF(@TransactionID = 1 ) -- Purchase Request
		BEGIN
			IF @DepartmentID IS NULL OR @DepartmentID = 0
				SET @DepartmentID = -999

			SELECT  RH.Id TransactionHeaderID, 
				RH.DocumentNo DocNo, 
				RH.TransactionTypeCode,
				U.UserName firstName,
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				FORMAT(RH.RequestDate,'yyyy-MM-dd') CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(RD.UnitPrice *   RD.RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails RD WHERE RD.RequestHeaderID = RH.ID ) AS 'ValueOfRequest' ,
				C.Name 'CompanyName',
				ISNULL([dbo].[GET_LastApprovedUser](RH.TransactionTypeCode,RH.ID),'') AS LastApprovedUser,
				ISNULL([dbo].[GET_NetPendingApproval](RH.TransactionTypeCode,RH.ID),'') AS ApprovalTypename
			FROM dbo.RequestHeaders RH
			INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = RH.LocationID
			INNER JOIN Companies C On C.CompanyID = RH.PropertyID
			WHERE RH.TransactionTypeCode = @TransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND RH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN RH.DepartmentID ELSE @DepartmentID END
			AND RH.PropertyID = CASE WHEN @CompanyId = -999 THEN RH.PropertyID ELSE @CompanyId END
			AND CAST(RH.RequestDate AS DATE) BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @ToDate END
			AND RH.Id NOT IN (SELECT POS.RequestHeaderId from PoWisePRs POS WHERE POS.RequestHeaderID = RH.Id) 
			AND RH.IsApproved=1
		END
		ELSE IF( @TransactionID = 11) -- Issue Request
		BEGIN
			IF @DepartmentID IS NULL OR @DepartmentID = 0
				SET @DepartmentID = -999

			SELECT  RH.Id TransactionHeaderID, 
				RH.DocumentNo DocNo, 
				RH.TransactionTypeCode,
				U.UserName firstName,
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				FORMAT(RH.RequestDate,'yyyy-MM-dd') CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(RD.UnitPrice *   RD.RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails RD WHERE RD.RequestHeaderID = RH.ID ) AS 'ValueOfRequest' ,
				C.Name 'CompanyName',
				ISNULL([dbo].[GET_LastApprovedUser](RH.TransactionTypeCode,RH.ID),'') AS LastApprovedUser,
				ISNULL([dbo].[GET_NetPendingApproval](RH.TransactionTypeCode,RH.ID),'') AS ApprovalTypename
			FROM dbo.RequestHeaders RH
			INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = RH.LocationID
			INNER JOIN Companies C On C.CompanyID = RH.PropertyID
			WHERE RH.TransactionTypeCode = @TransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND RH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN RH.DepartmentID ELSE @DepartmentID END
			AND RH.PropertyID = CASE WHEN @CompanyId = -999 THEN RH.PropertyID ELSE @CompanyId END
			AND CAST(RH.RequestDate AS DATE) BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @ToDate END
			AND RH.IsApproved=1
		END
		ELSE IF(@TransactionID = 78) --2026-08-10 Tharuka Production Process Plan (PL)
		BEGIN
			SELECT	PCH.ID													AS TransactionHeaderID,	-- ADDED - required by the UI
					PCH.DocumentNo											AS DocNo,
					ISNULL(TT.UserName,'')									AS firstName,			-- CHANGED - ISNULL guard
					FORMAT(PCH.RequestedDate,'yyyy-MM-dd')					AS CreatedDate,			-- ADDED - config maps "Requested Date" -> CreatedDate
					FORMAT(PCH.TxnDate,'yyyy-MM-dd')						AS DocumentDate,		-- ADDED (optional column)
					ISNULL(L.Name,'')										AS Location,			-- CHANGED - ISNULL guard
					CAST(ISNULL(D.RequestedQuantity,0) AS DECIMAL(18,3))	AS RequestedQuantity,	-- CHANGED - header level SUM, no longer one row per line
					ISNULL(D.Unit,'')										AS Unit,				-- CHANGED - 'Multiple' when the plan mixes units
					ISNULL(D.ItemCount,0)									AS NoOfItems,			-- ADDED (optional column)
					ISNULL(C.Name,'')										AS CompanyName,
					ISNULL(PCH.Remarks,'')									AS Remarks				-- ADDED (optional column)
			FROM ProductionConsolidateHeader PCH
			INNER JOIN Locations L			ON L.Id			= PCH.LocationID
			INNER JOIN #TempUserTable TT	ON TT.Id		= PCH.UserID
			INNER JOIN Companies C			ON C.CompanyID	= PCH.PropertyID
			OUTER APPLY (	-- ADDED - aggregates the plan lines instead of joining them (this is what removes the duplicated rows)
				SELECT	SUM(ISNULL(PCD.RequestedQTY,0))								AS RequestedQuantity,
						COUNT(*)													AS ItemCount,
						CASE WHEN COUNT(DISTINCT U.Name) > 1 THEN 'Multiple'
							 ELSE MAX(U.Name) END									AS Unit
				FROM ProductionConsolidateDetails PCD
				LEFT JOIN Units U ON U.Id = PCD.MasterUnitID
				WHERE PCD.HeaderID = PCH.ID
			) D
			WHERE PCH.Status = 'P'
			AND PCH.PropertyID = CASE WHEN @CompanyId = -999 THEN PCH.PropertyID ELSE @CompanyId END	-- ADDED - company filter
			AND PCH.LocationID = CASE WHEN @LocationID IS NULL OR @LocationID IN (0,-999)				-- CHANGED - also handle -999 (--All Locations--)
									 THEN PCH.LocationID ELSE @LocationID END
			AND CAST(PCH.RequestedDate AS DATE) BETWEEN													-- CHANGED - NULL / '' safe date range
				  CASE WHEN @FromDate IS NULL OR @FromDate = '' THEN CAST(PCH.RequestedDate AS DATE) ELSE CAST(@FromDate AS DATE) END
			  AND CASE WHEN @ToDate   IS NULL OR @ToDate   = '' THEN CAST(PCH.RequestedDate AS DATE) ELSE CAST(@ToDate   AS DATE) END
			ORDER BY PCH.ID DESC
		END
		ELSE IF(@TransactionID = 8 OR @TransactionID = 14) -- Transfer Request, Damage Request Note
		BEGIN

			IF(@LocationID IS NULL OR @LocationID =0 )
			BEGIN
				SET @LocationID = -999
				SET @DepartmentID = -999
			END
			SELECT DISTINCT 
							req.Id TransactionHeaderID,
							CASE WHEN  @TransactionID=8 THEN (SELECT TOP 1 NAME FROM Locations WHERE ID=req.LocationID)
							WHEN  @TransactionID=14 THEN LO.Name
							END AS Location ,
							req.Id AS 'PIID',
							req.RequestType,
							req.DocumentNo DocNo,
							FORMAT(req.RequestDate,'yyyy-MM-dd') AS 'HeadersCreatedDate',
							req.DocumentStatus AS Status,
							1 AS 'JobNo',
							req.IsApproved,
							req.Remarks,
							req.DepartmentID AS 'DepartmentID',
							1 AS 'TransferLocation',
							CURRENT_TIMESTAMP AS 'TimeStamp',
							1 AS 'TransactionTypeID', 
							userName,
							password,
							userName AS 'firstname',
							lastName,
							up.createdUserID,
							req.RequestDate AS 'CreatedDate',
							req.RequestDate AS 'LastModDate',
							up.isActive
					, req.UserProfileID AS 'ReqUser'
					, up.firstName+' '+up.lastName AS 'ReqUserName'
					, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = req.Id AND req.Flag=0) AS 'ValueOfRequest' ,
					 ISNULL([dbo].[GET_NetPendingApproval](req.TransactionTypeCode,req.ID),'') AS ApprovalTypename
					 ,[dbo].[GET_LastApprovedUser](@TransactionID, req.Id) AS LastApprovedUser,
					 (SELECT Name FROM Locations WHERE Id = Req.TransferLocation) AS 'TransferLocName'
					 ,C.Name 'CompanyName'
					INTO #TempRequsetApproval
				FROM  dbo.RequestHeaders req 
				INNER JOIN  #TempUserTable up ON up.Id = req.UserProfileID
				LEFT JOIN LOCATIONS LO ON LO.ID = REQ.LOCATIONID
				INNER JOIN Companies C ON C.CompanyID =  req.PropertyID
				WHERE req.TransactionTypeCode = @TransactionID AND req.DocumentStatus <> 'X' AND  req.DocumentStatus <> 'C'
				AND FORMAT(req.RequestDate,'yyyy-MM-dd') BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN FORMAT(req.RequestDate,'yyyy-MM-dd') ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN FORMAT(req.RequestDate,'yyyy-MM-dd') ELSE @ToDate END
				AND req.LocationID =  CASE WHEN @LocationID =-999 THEN req.LocationID ELSE @LocationID END
			
	
			SELECT * FROM #TempRequsetApproval 	
		END
	END
	ELSE IF (@TransactionStatusID =2) -- Approval
	BEGIN
		IF(@TransactionID = 76) -- Procurement Approval
		BEGIN

			; WITH FilterTable AS (
				SELECT 
			PCR.DocumentNo DocNo,FORMAT( PCR.InitiatedDate,'yyyy-MM-dd') InitiatedDate,PCS.Name Status,PCR.GeneralDescription,ET.EvaluationTemplateName,PCR.UserProfileId,
			DENSE_RANK() OVER (PARTITION BY PCR.DocumentNo ORDER BY SeqID) AS rankNo,
			PCR.Id TransactionHeaderID
		
			FROM
			ProcurementRequest PCR
			INNER JOIN EvaluationTemplate ET ON ET.ID = PCR.EvaluationCriteriaID
			LEFT JOIN ProcurementStatus PCS ON PCS.ID = PCR.StatusID
			WHERE PCR.CompanyID = @CompanyId AND PCR.LocationID = @LocationID AND PCR.StatusID =1 AND PCR.IsApprove=0 
			AND CAST(PCR.InitiatedDate AS DATE)  BETWEEN CAST(@FromDate AS DATE)  AND CAST(@ToDate AS DATE) 
			)
			SELECT * FROM FilterTable
			WHERE FilterTable.rankNo =1 AND FilterTable.UserProfileId = @UserProfileId
	
		END


		IF(@TransactionID = 81)
		BEGIN

			
			insert into #PENINGPOHEADER 
			EXEC [dbo].[SP_SelectPeningTourGuideApprovalForUser]  @UserProfileId, @CompanyId,@TransactionID

			SELECT TG.Id TransactionHeaderID,TG.Code,TG.Description,TG.CommissionPercentage,TG.ContactNo,TG.Email
			FROM TourGuideCompanies TG
			INNER JOIN #PENINGPOHEADER PN ON TG.ID = PN.TransactionHeaderID AND PN.TransactionID  =@TransactionID
			WHERE TG.PropertyId =  CASE WHEN @CompanyId = -999 THEN TG.PropertyId ELSE @CompanyId END
			AND ISNULL(TG.IsApproved,0) = 0
			AND CAST(TG.CreatedDateTime AS DATE) BETWEEN @FromDate AND @ToDate
		END

		IF (@TransactionID = 82)
		BEGIN

		insert into #PENINGPOHEADER 
		EXEC [dbo].[SP_SelectPeningTourGuideApprovalForUser]  @UserProfileId, @CompanyId,@TransactionID

		

			SELECT TG.Id TransactionHeaderID,TG.Code,TG.Description,TG.CommissionPercentage,TG.ContactNo,TG.Email
			FROM TourGuideMaster TG
			INNER JOIN #PENINGPOHEADER PN ON TG.ID = PN.TransactionHeaderID AND PN.TransactionID  =@TransactionID
			WHERE TG.PropertyId =  CASE WHEN @CompanyId = -999 THEN TG.PropertyId ELSE @CompanyId END
			AND ISNULL(TG.IsApproved,0) = 0
			AND CAST(TG.CreatedDateTime AS DATE) BETWEEN @FromDate AND @ToDate

		END

		--added by isuru 2026-10-28
		--Reason: Supplier Grading (SGR) approval - documents waiting for this user's approval level
		--        (same rules as Tour Guide: lowest open SeqID per document, ApprovalLogs.ApprovalUserID)
		IF (@TransactionID = (SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'))
		BEGIN
			;WITH NextLevel AS (
				SELECT AL.TransactionHeaderID, MIN(AL.SeqID) AS SeqID
				FROM dbo.ApprovalLogs AL
				WHERE AL.TransactionID = @TransactionID
				  AND AL.IsComplete = 0
				  AND AL.PropertyID = CASE WHEN @CompanyId = -999 THEN AL.PropertyID ELSE @CompanyId END
				GROUP BY AL.TransactionHeaderID
			)
			SELECT SEH.ID AS TransactionHeaderID,
				   SEH.DocumentNumber,
				   S.Code AS SupplierCode,
				   S.Name AS SupplierName,
				   ET.EvaluationTemplateName,
				   CAST(SEH.TotalScore AS DECIMAL(18,2)) AS TotalScore,
				   (SELECT COUNT(DISTINCT D.StockTransactionHeaderID)
					FROM dbo.SupplierEvaluationDetail D
					WHERE D.EvaluationHeaderID = SEH.ID) AS Documents,
				   FORMAT(SEH.CreatedDate, 'yyyy-MM-dd') AS CreatedDate,
				   U.UserName AS CreatedUser
			FROM dbo.SupplierEvaluationHeader SEH
			INNER JOIN NextLevel NL ON NL.TransactionHeaderID = SEH.ID
			INNER JOIN dbo.Suppliers S ON S.ID = SEH.SupplierID
			LEFT JOIN dbo.EvaluationTemplate ET ON ET.ID = SEH.EvaluationTemplateID
			LEFT JOIN #TempApprovalData U ON U.Id = SEH.CreatedUserId
			WHERE SEH.PropertyID = CASE WHEN @CompanyId = -999 THEN SEH.PropertyID ELSE @CompanyId END
			  AND ISNULL(SEH.IsApproved, 0) = 0
			  AND SEH.DocumentStatus = 'P'
			  AND CAST(SEH.CreatedDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
			  AND EXISTS (SELECT 1
						  FROM dbo.ApprovalLogs AL
						  WHERE AL.TransactionID = @TransactionID
							AND AL.TransactionHeaderID = SEH.ID
							AND AL.SeqID = NL.SeqID
							AND AL.IsComplete = 0
							AND AL.ApprovalUserID = @UserProfileId)
			ORDER BY SEH.ID;
		END
		--End

		---Approval for Transfer Note
		IF (@TransactionID = 5)
		BEGIN

				SELECT GA.Id AS HeaderId,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate
				,GA.ApprovalDocNo,GA.ReferenceNo,AT.ApprovalTypeName,
				GA.seqid, DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,GA.TransactionType,GA.Status,l.Id as LocationID,
				GA.ApprovallevelId
				,GA.ApprovalDocNo DocumentNo,CONVERT(DATE,GA.CreatedDate) TransactionDate,U.Username AS CreatedUser
				,L2.Name ToLocation,GA.Id TransactionHeaderID
				 INTO #TempGrnApprovalTable 
				 FROM GRNApprovalLog GA
				INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
				INNER JOIN Locations L ON L.Id = GA.LocationId
				LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
				INNER JOIN Locations L2 ON L2.ID = GA.ToLocationID
				WHERE GA.CompanyId = CASE WHEN @CompanyId = -999 THEN GA.CompanyId ELSE @CompanyId END
				AND l.Id = CASE WHEN @LocationID IS NULL THEN l.Id ELSE (CASE WHEN @LocationID =-999 THEN l.Id ELSE @LocationID END) END 
				AND GA.TransactionType = 'TO' 
				AND GA.Status = 'P'
				
				ORDER BY GA.Id DESC


				
				
				select * from
				#TempGrnApprovalTable
				where
				RowNum =1 
				AND UserProfileId = @UserProfileID
				AND TransactionType = 'TO'
				AND Status = 'P'
				AND LocationID = CASE WHEN @LocationID IS NULL THEN LocationID ELSE (CASE WHEN @LocationID =-999 THEN LocationID ELSE @LocationID END) END 
				order by HeaderId


		END


		--end


	END
	ELSE IF (@TransactionStatusID = 3) -- Rejection
	BEGIN
		IF(@TransactionID = 2)
		BEGIN
			IF @LocationID IS NULL OR @LocationID = 0
			SET @LocationID = -999

			IF(@IsCentralLogin = 1)
			BEGIN
				SELECT DISTINCT H.ID TransactionHeaderID,
					S.Name AS SupplierName,
					H.SupplierID AS SupplierId,
					H.PoNo DocNo,
					U.UserName ReqUserProf,
					l.Name Location, 
					FORMAT(h.DocumentDate,'yyyy-MM-dd') DocumentDate,
					H.NetTotal POValue,
					ISNULL(H.Remarks,'') Remarks,
					C.name CompanyName
				FROM dbo.PoHeaders H
				INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
				INNER JOIN #TempUserTable U ON u.Id = H.UserProfileID
				INNER JOIN suppliers S ON S.ID = H.SupplierID
				INNER JOIN dbo.Locations L ON L.Id = H.LocationID
				INNER JOIN Companies C ON C.CompanyID = H.PropertyID
				WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' AND H.IsApproved = 1 --Added by ravindu 2025-12-08
				AND H.PropertyID = CASE WHEN @CompanyId = -999 THEN H.PropertyID ELSE @CompanyId END
				AND H.DocumentDate BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN H.DocumentDate ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN H.DocumentDate ELSE @ToDate END
				AND H.LocationID = CASE WHEN @LocationID =-999 THEN H.LocationID ELSE @LocationID END
				GROUP BY H.ID, S.Name, H.SupplierID, H.PoNo, U.UserName, L.Name, H.DocumentDate, H.NetTotal, H.Remarks, C.Name
				HAVING SUM(PD.ReceivedQuantity) = 0;
			END
			ELSE
			BEGIN
				SELECT DISTINCT H.ID TransactionHeaderID,
					S.Name AS SupplierName,
					H.SupplierID AS SupplierId,
					H.PoNo DocNo,
					U.UserName ReqUserProf,
					l.Name Location, 
					FORMAT(h.DocumentDate,'yyyy-MM-dd') DocumentDate,
					H.NetTotal POValue,
					ISNULL(H.Remarks,'') Remarks,
					C.Name CompanyName
				FROM dbo.PoHeaders H
				INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
				INNER JOIN #TempUserTable U ON u.Id = H.UserProfileID
				INNER JOIN suppliers S ON S.ID = H.SupplierID
				INNER JOIN dbo.Locations L ON L.Id = H.LocationID
				INNER JOIN Companies C ON C.CompanyID = H.PropertyID
				WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' AND H.IsApproved = 1 --Added by ravindu 2025-12-08
				AND H.DocumentDate BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN H.DocumentDate ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN H.DocumentDate ELSE @ToDate END
				AND H.LocationID = CASE WHEN @LocationID =-999 THEN H.LocationID ELSE @LocationID END
				AND H.PropertyID = CASE WHEN @CompanyId = -999 THEN H.PropertyID ELSE @CompanyId END
				GROUP BY H.ID, S.Name, H.SupplierID, H.PoNo, U.UserName, L.Name, H.DocumentDate, H.NetTotal, H.Remarks, C.Name
				HAVING SUM(PD.ReceivedQuantity) = 0;
			END	
		END
		ELSE IF(@TransactionID = 1 )
		BEGIN
			IF @DepartmentID IS NULL OR @DepartmentID = 0
				SET @DepartmentID = -999

			SELECT  RH.Id TransactionHeaderID, 
				RH.DocumentNo DocNo, 
				RH.TransactionTypeCode,
				U.UserName firstName,
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				FORMAT(RH.RequestDate,'yyyy-MM-dd') CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(RD.UnitPrice *   RD.RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails RD WHERE RD.RequestHeaderID = RH.ID ) AS 'ValueOfRequest' ,
				C.Name 'CompanyName',
				ISNULL([dbo].[GET_LastApprovedUser](RH.TransactionTypeCode,RH.ID),'') AS LastApprovedUser,
				ISNULL([dbo].[GET_NetPendingApproval](RH.TransactionTypeCode,RH.ID),'') AS ApprovalTypename
			FROM dbo.RequestHeaders RH
			INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = RH.LocationID
			INNER JOIN Companies C On C.CompanyID = RH.PropertyID
			WHERE RH.TransactionTypeCode = @TransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND RH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN RH.DepartmentID ELSE @DepartmentID END
			AND RH.PropertyID = CASE WHEN @CompanyId = -999 THEN RH.PropertyID ELSE @CompanyId END
			AND CAST(RH.RequestDate AS DATE) BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @ToDate END
			AND RH.Id NOT IN (SELECT POS.RequestHeaderId from PoWisePRs POS WHERE POS.RequestHeaderID = RH.Id) 
			AND RH.IsApproved=1
		END
		ELSE IF( @TransactionID = 11)
		BEGIN
			IF @DepartmentID IS NULL OR @DepartmentID = 0
				SET @DepartmentID = -999

			SELECT  RH.Id TransactionHeaderID, 
				RH.DocumentNo DocNo, 
				RH.TransactionTypeCode,
				U.UserName firstName,
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				FORMAT(RH.RequestDate,'yyyy-MM-dd') CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(RD.UnitPrice *   RD.RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails RD WHERE RD.RequestHeaderID = RH.ID ) AS 'ValueOfRequest' ,
				C.Name 'CompanyName',
				ISNULL([dbo].[GET_LastApprovedUser](RH.TransactionTypeCode,RH.ID),'') AS LastApprovedUser,
				ISNULL([dbo].[GET_NetPendingApproval](RH.TransactionTypeCode,RH.ID),'') AS ApprovalTypename
			FROM dbo.RequestHeaders RH
			INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = RH.LocationID
			INNER JOIN Companies C On C.CompanyID = RH.PropertyID
			WHERE RH.TransactionTypeCode = @TransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND RH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN RH.DepartmentID ELSE @DepartmentID END
			AND RH.PropertyID = CASE WHEN @CompanyId = -999 THEN RH.PropertyID ELSE @CompanyId END
			AND CAST(RH.RequestDate AS DATE) BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN CAST(RH.RequestDate AS DATE) ELSE @ToDate END
			AND RH.IsApproved=1
		END
		ELSE IF(@TransactionID = 78) --2026-08-10 Tharuka Production Process Plan (PL)
		BEGIN
			SELECT	PCH.ID													AS TransactionHeaderID,	
					PCH.DocumentNo											AS DocNo,
					ISNULL(TT.UserName,'')									AS firstName,			
					FORMAT(PCH.RequestedDate,'yyyy-MM-dd')					AS CreatedDate,			
					FORMAT(PCH.TxnDate,'yyyy-MM-dd')						AS DocumentDate,		
					ISNULL(L.Name,'')										AS Location,			
					CAST(ISNULL(D.RequestedQuantity,0) AS DECIMAL(18,3))	AS RequestedQuantity,	
					ISNULL(D.Unit,'')										AS Unit,				
					ISNULL(D.ItemCount,0)									AS NoOfItems,			
					ISNULL(C.Name,'')										AS CompanyName,
					ISNULL(PCH.Remarks,'')									AS Remarks				
			FROM ProductionConsolidateHeader PCH
			INNER JOIN Locations L			ON L.Id			= PCH.LocationID
			INNER JOIN #TempUserTable TT	ON TT.Id		= PCH.UserID
			INNER JOIN Companies C			ON C.CompanyID	= PCH.PropertyID
			OUTER APPLY (	
				SELECT	SUM(ISNULL(PCD.RequestedQTY,0))								AS RequestedQuantity,
						COUNT(*)													AS ItemCount,
						CASE WHEN COUNT(DISTINCT U.Name) > 1 THEN 'Multiple'
							 ELSE MAX(U.Name) END									AS Unit
				FROM ProductionConsolidateDetails PCD
				LEFT JOIN Units U ON U.Id = PCD.MasterUnitID
				WHERE PCD.HeaderID = PCH.ID
			) D
			WHERE PCH.Status = 'P'
			AND PCH.PropertyID = CASE WHEN @CompanyId = -999 THEN PCH.PropertyID ELSE @CompanyId END	
			AND PCH.LocationID = CASE WHEN @LocationID IS NULL OR @LocationID IN (0,-999)				
									 THEN PCH.LocationID ELSE @LocationID END
			AND CAST(PCH.RequestedDate AS DATE) BETWEEN												
				  CASE WHEN @FromDate IS NULL OR @FromDate = '' THEN CAST(PCH.RequestedDate AS DATE) ELSE CAST(@FromDate AS DATE) END
			  AND CASE WHEN @ToDate   IS NULL OR @ToDate   = '' THEN CAST(PCH.RequestedDate AS DATE) ELSE CAST(@ToDate   AS DATE) END
			ORDER BY PCH.ID DESC
		END
		ELSE IF(@TransactionID = 8 OR @TransactionID = 14)
		BEGIN

			IF(@LocationID IS NULL OR @LocationID =0 )
			BEGIN
				SET @LocationID = -999
				SET @DepartmentID = -999
			END
			SELECT DISTINCT 
							req.Id TransactionHeaderID,
							CASE WHEN  @TransactionID=8 THEN (SELECT TOP 1 NAME FROM Locations WHERE ID=req.LocationID)
							WHEN  @TransactionID=14 THEN LO.Name
							END AS Location ,
							req.Id AS 'PIID',
							req.RequestType,
							req.DocumentNo DocNo,
							FORMAT(req.RequestDate,'yyyy-MM-dd') AS 'HeadersCreatedDate',
							req.DocumentStatus AS Status,
							1 AS 'JobNo',
							req.IsApproved,
							req.Remarks,
							req.DepartmentID AS 'DepartmentID',
							1 AS 'TransferLocation',
							CURRENT_TIMESTAMP AS 'TimeStamp',
							1 AS 'TransactionTypeID', 
							userName,
							password,
							userName AS 'firstname',
							lastName,
							up.createdUserID,
							req.RequestDate AS 'CreatedDate',
							req.RequestDate AS 'LastModDate',
							up.isActive
					, req.UserProfileID AS 'ReqUser'
					, up.firstName+' '+up.lastName AS 'ReqUserName'
					, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = req.Id AND req.Flag=0) AS 'ValueOfRequest' ,
					 ISNULL([dbo].[GET_NetPendingApproval](req.TransactionTypeCode,req.ID),'') AS ApprovalTypename
					 ,[dbo].[GET_LastApprovedUser](@TransactionID, req.Id) AS LastApprovedUser,
					 (SELECT Name FROM Locations WHERE Id = Req.TransferLocation) AS 'TransferLocName'
					 ,C.Name 'CompanyName'
					INTO #TempRequsetApprovalRejection
				FROM  dbo.RequestHeaders req 
				INNER JOIN  #TempUserTable up ON up.Id = req.UserProfileID
				LEFT JOIN LOCATIONS LO ON LO.ID = REQ.LOCATIONID
				INNER JOIN Companies C ON C.CompanyID =  req.PropertyID
				WHERE req.TransactionTypeCode = @TransactionID AND req.DocumentStatus <> 'X' AND  req.DocumentStatus <> 'C'
				AND FORMAT(req.RequestDate,'yyyy-MM-dd') BETWEEN 
				CASE WHEN @FromDate IS NULL OR @FromDate ='' THEN FORMAT(req.RequestDate,'yyyy-MM-dd') ELSE @FromDate END
				AND  CASE WHEN @ToDate IS NULL OR @ToDate ='' THEN FORMAT(req.RequestDate,'yyyy-MM-dd') ELSE @ToDate END
				AND req.LocationID =  CASE WHEN @LocationID =-999 THEN req.LocationID ELSE @LocationID END
			
	
			SELECT * FROM #TempRequsetApprovalRejection 	
		END	
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

