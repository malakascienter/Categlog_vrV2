/* =============================================================================================
   15_ALTER_SP_Get_CommonPendingTransactionHeaderDetail_ProductionPlan.sql
   ---------------------------------------------------------------------------------------------
   Screen      : Transaction Completion  (#/processdata/CommonTransactionStatus/1) - Details tab
   Transaction : 78 - PL / Production Process Plan
   Purpose     : Fill the "Document No / Location / Requested User / ..." summary strip that is
                 drawn above the Details grid.

   Change      : one new "ELSE IF(@TransactionID = 78)" branch appended at the end of the
                 existing IF chain. Nothing else in the SP has been modified.
                 Search this file for "ADDED 2026-08-10".

   Optional    : the Headers grid works without this script. Run it only if you also want the
                 summary strip populated (script 14 is the companion for the Details grid).
   ============================================================================================= */

-- =============================================
-- Author:       Nivesh
-- Create date:  2025-03-26
-- Description:  Get detail of header data
-- =============================================
-- SP_Get_CommonPendingTransactionHeaderDetail 1,4168,5,3075

CREATE PROCEDURE [dbo].[SP_Get_CommonPendingTransactionHeaderDetail] 
    @CompanyId INT,
    @UserProfileId INT,
    @TransactionID INT,
    @TransactionHeaderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Table variable instead of temporary table
    DECLARE @YourTargetTable TABLE (
        columnName NVARCHAR(255),
        value NVARCHAR(255)
    );

	DECLARE @IsCentralLogin BIT
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
    IF (@TransactionID = 2)
    BEGIN
        ;WITH PoData AS (
            SELECT DISTINCT 
                H.ID AS TransactionHeaderID,
                S.Name AS SupplierName,
                H.SupplierID AS SupplierId,
                H.PoNo,
                U.UserName AS ReqUserProf,
                L.Name AS Location, 
                FORMAT(H.DocumentDate, 'yyyy-MM-dd') AS DocumentDate,
                H.NetTotal AS POValue,
                ISNULL(H.Remarks, '') AS Remarks,
                C.Name AS CompanyName
            FROM dbo.PoHeaders H
            INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
            INNER JOIN [dbo].[CentralUsers] U ON U.Id = H.UserProfileID
            INNER JOIN suppliers S ON S.ID = H.SupplierID
            INNER JOIN dbo.Locations L ON L.Id = H.LocationID
            INNER JOIN Companies C ON C.CompanyID = H.PropertyID
            WHERE H.DocumentStatus NOT IN ('C', 'X') 
              AND H.PropertyID = @CompanyId
              AND H.Id = @TransactionHeaderID
            GROUP BY H.ID, S.Name, H.SupplierID, H.PoNo, U.UserName, L.Name, H.DocumentDate, H.NetTotal, H.Remarks, C.Name
            HAVING SUM(PD.ReceivedQuantity) = 0
        )
        
        -- Insert data into the table variable
        INSERT INTO @YourTargetTable (columnName, value)
        SELECT 
            v.ColumnName as columnName , 
            v.ColumnValue as value
        FROM PoData p
        CROSS APPLY (
            VALUES
                ('SupplierName', p.SupplierName),
                ('PoNo', p.PoNo),
                ('ReqUserProf', p.ReqUserProf),
                ('Location', p.Location),
                ('DocumentDate', p.DocumentDate),
                ('POValue', CAST(p.POValue AS NVARCHAR(255)))
        ) v(ColumnName, ColumnValue);

        -- Get the number of rows
        SELECT * FROM @YourTargetTable;
        
    END
	ELSE IF (@TransactionID =1 OR @TransactionID =11)
	BEGIN
		SELECT L.Name AS LocationName, D.Name AS DepartmentName, convert(varchar(max),'' ) TransferLocationName, RH.DocumentNo, FORMAT(RH.RequestDate,'yyyy-MM-dd') RequestDate, RH.Id ,RH.RequestType, U.UserName AS RequestedUser ,
				CASE RH.RequestType
						WHEN 'RP' THEN 'PR Number'
						WHEN 'RI' THEN 'IR Number'
					END
					AS DocumentType, RH.TransferLocation,
					(SELECT SUM(ISNULL(UnitPrice *   RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = RH.ID ) AS 'ValueOfRequest' 
		INTO #TempDataCentral
		FROM dbo.RequestHeaders AS RH
		INNER  JOIN dbo.Locations AS L ON RH.LocationID = L.Id
		LEFT OUTER JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
		INNER JOIN #TempUserTable  AS U ON RH.UserProfileID = U.Id
		INNER JOIN TransactionTypes TT ON TT.Code =RH.RequestType
		WHERE RH.Id = @TransactionHeaderID AND RH.PropertyID = @CompanyId
		AND RH.TransactionTypeCode = @TransactionID
		 
		 ;WITH RequestData AS (
          SELECT * FROM #TempDataCentral
        )
        
        -- Insert data into the table variable
        INSERT INTO @YourTargetTable (columnName, value)
        SELECT 
            v.ColumnName as columnName , 
            v.ColumnValue as value
        FROM RequestData p
        CROSS APPLY (
            VALUES
                ('Location', p.LocationName),
                ('Department', p.DepartmentName),
                (p.DocumentType, p.DocumentNo),
                ('Request Date', p.RequestDate),
                ('Requested User', p.RequestedUser),
                ('Net Total', CAST(p.ValueOfRequest AS NVARCHAR(255)))
        ) v(ColumnName, ColumnValue);

		      -- Get the number of rows
        SELECT * FROM @YourTargetTable;
	END
	ELSE IF (@TransactionID = 8)
	BEGIN

			;WITH RequestData AS (
            	SELECT L.Name AS LocationName, D.Name AS DepartmentName, CASE 
            WHEN RH.RequestType = 'RT' THEN (SELECT Name FROM Locations l WHERE l.id = RH.TransferLocation)
            ELSE ''
        END AS TransferLocationName, RH.DocumentNo, FORMAT(RH.RequestDate,'yyyy-MM-dd') RequestDate, RH.Id ,RH.RequestType, U.UserName AS RequestedUser ,
					CASE RH.RequestType
						 WHEN 'RP' THEN 'PR Number'
						 WHEN 'RI' THEN 'Issue Request No'
						 WHEN 'RD' THEN 'DR Number'
						 WHEN 'RT' THEN 'TO Number'
						 WHEN 'MR' THEN 'MR Number'
					 END
					 AS DocumentType, RH.TransferLocation,
					 (SELECT SUM(ISNULL(UnitPrice *   RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = RH.ID ) AS 'ValueOfRequest' 
			FROM dbo.RequestHeaders AS RH
			INNER  JOIN dbo.Locations AS L ON RH.LocationID = L.Id
			Left Outer JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	
			INNER JOIN [dbo].[CentralUsers]  AS U ON RH.UserProfileID = U.Id
			INNER JOIN TransactionTypes TT ON TT.Code =RH.RequestType
			WHERE RH.Id = @TransactionHeaderID AND RH.PropertyID = @CompanyId
        )
        INSERT INTO @YourTargetTable (columnName, value)
        SELECT 
            v.ColumnName as columnName , 
            v.ColumnValue as value
        FROM RequestData p
        CROSS APPLY (
            VALUES
                ('Location', p.LocationName),
				('Transfer Location',p.TransferLocationName),
                ('TO Number', p.DocumentNo),
                ('Request Date', p.RequestDate),
                ('Requested User', p.RequestedUser),
                ('Net Total', CAST(p.ValueOfRequest AS NVARCHAR(255)))
        ) v(ColumnName, ColumnValue);

        SELECT * FROM @YourTargetTable;
	END
	ELSE IF (@TransactionID = 14)
	BEGIN

			;WITH RequestData AS (
            	SELECT L.Name AS LocationName,
				D.Name AS DepartmentName,
		RH.DocumentNo, FORMAT(RH.RequestDate,'yyyy-MM-dd') RequestDate, RH.Id ,RH.RequestType, U.UserName AS RequestedUser ,
					CASE RH.RequestType
						 WHEN 'RP' THEN 'PR Number'
						 WHEN 'RI' THEN 'Issue Request No'
						 WHEN 'RD' THEN 'DR Number'
						 WHEN 'RT' THEN 'TO Number'
						 WHEN 'MR' THEN 'MR Number'
					 END
					 AS DocumentType, RH.TransferLocation,
					 (SELECT SUM(ISNULL(UnitPrice *   RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = RH.ID ) AS 'ValueOfRequest' 
			FROM dbo.RequestHeaders AS RH
			INNER  JOIN dbo.Locations AS L ON RH.LocationID = L.Id
			Left Outer JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	
			INNER JOIN [dbo].[CentralUsers]  AS U ON RH.UserProfileID = U.Id
			INNER JOIN TransactionTypes TT ON TT.Code =RH.RequestType
			WHERE RH.Id = @TransactionHeaderID AND RH.PropertyID = @CompanyId
        )
        INSERT INTO @YourTargetTable (columnName, value)
        SELECT 
            v.ColumnName as columnName , 
            v.ColumnValue as value
        FROM RequestData p
        CROSS APPLY (
            VALUES
                ('Location', p.LocationName),
				('Department', p.DepartmentName),
                ('TO Number', p.DocumentNo),
                ('Request Date', p.RequestDate),
                ('Requested User', p.RequestedUser),
                ('Net Total', CAST(p.ValueOfRequest AS NVARCHAR(255)))
        ) v(ColumnName, ColumnValue);

        SELECT * FROM @YourTargetTable;
	END
	ELSE IF(@TransactionID = 76)
	BEGIN
		;WITH RequestData AS (
            SELECT PCR.DocumentNo DocNo, L.Name Location, ET.EvaluationTemplateName Template, FORMAT(PCR.InitiatedDate,'yyyy-MM-dd') InitiateDate
			FROM ProcurementRequest PCR
			INNER JOIN TempStockItemRequest TSIR ON TSIR.Id = PCR.StockItemRequestID
			INNER JOIN EvaluationTemplate ET ON ET.ID = PCR.EvaluationCriteriaID
			INNER JOIN Locations L ON L.Id = PCR.LocationID
			WHERE PCR.ID = @TransactionHeaderID AND PCR.CompanyID = @CompanyId
				)
				INSERT INTO @YourTargetTable (columnName, value)
				SELECT 
					v.ColumnName as columnName , 
					v.ColumnValue as value
				FROM RequestData p
				CROSS APPLY (
					VALUES
						('Location', p.Location),
						('Document No', p.DocNo),
						('Template', p.Template),
						('Initiate Date', p.InitiateDate)
				) v(ColumnName, ColumnValue);

        SELECT * FROM @YourTargetTable;		
	END
    ELSE IF(@TransactionID = 81)
	BEGIN
	;WITH RequestData AS (
		SELECT TG.Code,TG.Description,CAST(TG.CommissionPercentage AS varchar) CommissionPercentage,TG.ContactNo,TG.Email
		FROM TourGuideCompanies TG
		WHERE TG.ID = @TransactionHeaderID 
		AND TG.PropertyId = @CompanyId)
			INSERT INTO @YourTargetTable (columnName, value)
			SELECT 
				v.ColumnName as columnName , 
				v.ColumnValue as value
			FROM RequestData p
			CROSS APPLY (
				VALUES
					('Code', p.Code),
					('Description', p.Description),
					('CommissionPercentage', p.CommissionPercentage),
					('Contact No', p.ContactNo),
					('Email', p.Email)
			) v(ColumnName, ColumnValue);

    SELECT * FROM @YourTargetTable;		
	END

	--added by isuru 2026-10-28
	--Reason: Supplier Grading (SGR) approval - header details of the submit
	ELSE IF(@TransactionID = (SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'))
	BEGIN
		;WITH RequestData AS (
			SELECT SEH.DocumentNumber,
				   S.Code AS SupplierCode,
				   S.Name AS SupplierName,
				   ET.EvaluationTemplateName,
				   CAST(CAST(SEH.TotalScore AS DECIMAL(18,2)) AS NVARCHAR(50)) AS TotalScore,
				   ISNULL(SEH.SupplierGrade, '-') AS SuggestedGrade, --changed by isuru 2026-10-29 (was Documents Graded)
				   --added by isuru 2026-10-29: blacklist reason for the approver (stored by SP_CalculateSupplierGrade)
				   CASE WHEN SEH.GradePercentage IS NULL THEN '-'
						ELSE CAST(CAST(SEH.GradePercentage AS DECIMAL(9,2)) AS NVARCHAR(20)) + ' %'
							 + CASE WHEN ISNULL(C.SupplierGradingBlackListPercentage, 0) > 0
									THEN ' (blacklist below ' + CAST(CAST(C.SupplierGradingBlackListPercentage AS DECIMAL(9,2)) AS NVARCHAR(20)) + ' %)'
									ELSE '' END
				   END AS PassPercentage,
				   CASE WHEN SEH.BenchMarkFailedGRNs IS NULL THEN '-'
						ELSE CAST(SEH.BenchMarkFailedGRNs AS NVARCHAR(20))
							 + CASE WHEN ISNULL(C.BenchMarkFailCount, 0) > 0
									THEN ' (blacklist at ' + CAST(C.BenchMarkFailCount AS NVARCHAR(20)) + ')'
									ELSE '' END
				   END AS BenchMarkFailCount,
				   FORMAT(SEH.CreatedDate, 'yyyy-MM-dd HH:mm') AS CreatedDate
			FROM dbo.SupplierEvaluationHeader SEH
			INNER JOIN dbo.Suppliers S ON S.ID = SEH.SupplierID
			LEFT JOIN dbo.EvaluationTemplate ET ON ET.ID = SEH.EvaluationTemplateID
			LEFT JOIN dbo.Companies C ON C.CompanyID = SEH.PropertyID --added by isuru 2026-10-29
			WHERE SEH.ID = @TransactionHeaderID
			AND SEH.PropertyID = @CompanyId)
				INSERT INTO @YourTargetTable (columnName, value)
				SELECT
					v.ColumnName as columnName ,
					v.ColumnValue as value
				FROM RequestData p
				CROSS APPLY (
					VALUES
						('Document No', p.DocumentNumber),
						('Supplier Code', p.SupplierCode),
						('Supplier', p.SupplierName),
						('Evaluation Template', p.EvaluationTemplateName),
						('Total Score', p.TotalScore),
						('Pass Percentage', p.PassPercentage), --added by isuru 2026-10-29
						('Bench Mark Fail Count', p.BenchMarkFailCount), --added by isuru 2026-10-29
						('Suggested Grade', p.SuggestedGrade),
						('Submitted On', p.CreatedDate)
				) v(ColumnName, ColumnValue);

		SELECT * FROM @YourTargetTable;
	END
	--End

	ELSE IF(@TransactionID = 82)
	BEGIN
		;WITH RequestData AS (
			SELECT TG.Code,TG.Description,CAST(TG.CommissionPercentage AS varchar) CommissionPercentage,TG.ContactNo,TG.Email
			FROM TourGuideMaster TG
			WHERE TG.ID = @TransactionHeaderID 
			AND TG.PropertyId = @CompanyId)
				INSERT INTO @YourTargetTable (columnName, value)
				SELECT 
					v.ColumnName as columnName , 
					v.ColumnValue as value
				FROM RequestData p
				CROSS APPLY (
					VALUES
						('Code', p.Code),
						('Description', p.Description),
						('CommissionPercentage', p.CommissionPercentage),
						('Contact No', p.ContactNo),
						('Email', p.Email)
				) v(ColumnName, ColumnValue);

		SELECT * FROM @YourTargetTable;		
	END

	ELSE IF(@TransactionID = 5)
	BEGIN
		;WITH RequestData AS (

			SELECT GA.ApprovalDocNo,L.Name Location,L2.Name Location2,FORMAT(GA.CreatedDate,'yyyy-MM-dd') InitiateDate
			,U.UserName
			FROM GRNApprovalLog GA
			INNER JOIN CentralUsers U ON GA.CreatedUserId = U.Id
			INNER JOIN Locations L ON L.Id = GA.LocationId
			INNER JOIN Locations L2 ON L2.ID = GA.ToLocationID
			WHERE GA.Id = @TransactionHeaderID
			AND GA.CompanyId = @CompanyId
			)
				INSERT INTO @YourTargetTable (columnName, value)
				SELECT 
					v.ColumnName as columnName , 
					v.ColumnValue as value
				FROM RequestData p
				CROSS APPLY (
					VALUES
						('Document No', p.ApprovalDocNo),
						('Location', p.Location),
						('To Location', p.Location2),
						('Initiate Date', p.InitiateDate),
						('Requested User', p.UserName)
				) v(ColumnName, ColumnValue);

			SELECT * FROM @YourTargetTable;		
	END
	ELSE IF(@TransactionID = 78) -- ADDED 2026-08-10 - Production Process Plan (PL)
	BEGIN
		/* -----------------------------------------------------------------------------------
		   ADDED 2026-08-10
		   Fills the label / value summary strip shown above the Details grid. Without this
		   branch the strip stayed empty for Production Plans. Same shape as the other
		   branches: rows of (columnName, value) inserted into @YourTargetTable.
		   ----------------------------------------------------------------------------------- */
		;WITH PlanData AS (
			SELECT	PCH.DocumentNo								AS DocNo,
					ISNULL(L.Name,'')							AS Location,
					ISNULL(TT.UserName,'')						AS RequestedUser,
					FORMAT(PCH.TxnDate,'yyyy-MM-dd')			AS DocumentDate,
					FORMAT(PCH.RequestedDate,'yyyy-MM-dd')		AS RequestedDate,
					ISNULL(PCH.Remarks,'')						AS Remarks
			FROM ProductionConsolidateHeader PCH
			INNER JOIN Locations L			ON L.Id		= PCH.LocationID
			LEFT  JOIN #TempUserTable TT	ON TT.Id	= PCH.UserID
			WHERE PCH.ID = @TransactionHeaderID
			AND PCH.PropertyID = CASE WHEN @CompanyId = -999 THEN PCH.PropertyID ELSE @CompanyId END
		)
		INSERT INTO @YourTargetTable (columnName, value)
		SELECT	v.ColumnName	AS columnName,
				v.ColumnValue	AS value
		FROM PlanData p
		CROSS APPLY (
			VALUES
				('Document No',		p.DocNo),
				('Location',		p.Location),
				('Requested User',	p.RequestedUser),
				('Document Date',	p.DocumentDate),
				('Requested Date',	p.RequestedDate),
				('Remarks',			p.Remarks)
		) v(ColumnName, ColumnValue);

		SELECT * FROM @YourTargetTable;
	END
END

GO

