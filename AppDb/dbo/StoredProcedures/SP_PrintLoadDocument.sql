-- Last Modified by : Nivesh
-- Modified date	: 2025-07-23
-- [dbo].[SP_PrintLoadDocument] 1,85,-999,-999,3597,9212

CREATE PROCEDURE [dbo].[SP_PrintLoadDocument]
	@propertyId INT,
	@type VARCHAR(max),
	@deptId INT =-999,
	@supId INT =-999,
	@locationId INT= -999,
	@userid INT
AS
BEGIN

	declare @isPOApprovalForPrintPreview BIT,@IsPrintCopyDocLimit BIT,@TopDocLimit INT;

	DECLARE @IsRetail BIT;


	SELECT @IsRetail = ISNULL(IsRetail,0)
	FROM Companies
	WHERE CompanyID = @propertyId

	SET @TopDocLimit = 1000;

	DECLARE @UserWiseLocation TABLE  (
	Id INT,
	LocID INT
	)

	DECLARE @UserWiseDeparetment TABLE  (
		Id INT,
		DepID INT
	)

	INSERT INTO @UserWiseLocation
	SELECT UL.UserID Id , UL.LocationID LocID
	FROM
	UserWise_Location UL
	WHERE UL.CompanyId = @propertyId AND ul.LocationID = CASE WHEN @locationId = -999 THEN UL.LocationID ELSE @locationId END
	AND UL.UserID = @UserID

	INSERT INTO @UserWiseDeparetment
	SELECT ud.userId Id , UD.deptid DepID
	FROM UserWiseDepartments UD
	WHERE UD.companyId = @propertyId AND ud.deptid = CASE WHEN @deptId = -999 THEN ud.deptid ELSE @deptId END
	AND UD.UserID = @UserID

	select TOP (1) 
	@isPOApprovalForPrintPreview = isnull(isPOApprovalForPrintPreview,0) ,
	@IsPrintCopyDocLimit = ISNULL(IsPrintCopyDocLimit,0)
	from Companies 
	WHERE CompanyID = CASE WHEN @propertyId = -999 THEN CompanyID ELSE @propertyId END

	IF(@type='2' and @isPOApprovalForPrintPreview = 1 )
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT TOP (@TopDocLimit)  PH.Id AS id,  PH.PoNo +' '+' | '+ CONVERT(varchar(10), PH.DocumentDate, 111) +' '+' | '+ CASE WHEN PH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text  
			FROM dbo.PoHeaders PH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
			WHERE  PH.PropertyID = CASE WHEN @propertyId = -999 THEN   PH.PropertyID ELSE @propertyId END
			AND  PH.SupplierID = CASE WHEN @supId = -999 THEN  PH.SupplierID ELSE @supId END
			and IsApproved = 1 
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by PH.CreatedDate desc
		END
		ELSE -- Loading ALL Documents
		BEGIN
			SELECT   PH.Id AS id,  PH.PoNo +' '+' | '+ CONVERT(varchar(10), PH.DocumentDate, 111) +' '+' | '+ CASE WHEN PH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text  
			FROM dbo.PoHeaders PH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
			WHERE  PH.PropertyID = CASE WHEN @propertyId = -999 THEN   PH.PropertyID ELSE @propertyId END
			AND  PH.SupplierID = CASE WHEN @supId = -999 THEN  PH.SupplierID ELSE @supId END
			and IsApproved = 1 
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by PH.CreatedDate desc
		END
		
	END


	IF(@type='2' and @isPOApprovalForPrintPreview = 0 )
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT TOP (@TopDocLimit) PH.Id AS id, PH.PoNo +' '+' | '+ CONVERT(varchar(10), PH.DocumentDate, 111) +' '+' | '+ CASE WHEN PH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text  
			FROM dbo.PoHeaders PH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
			WHERE PH.PropertyID = CASE WHEN @propertyId = -999 THEN  PH.PropertyID ELSE @propertyId END
			AND PH.SupplierID = CASE WHEN @supId = -999 THEN PH.SupplierID ELSE @supId END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by PH.CreatedDate desc
		END
		ELSE
		BEGIN
			SELECT  PH.Id AS id, PH.PoNo +' '+' | '+ CONVERT(varchar(10), PH.DocumentDate, 111) +' '+' | '+ CASE WHEN PH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text  
			FROM dbo.PoHeaders PH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
			WHERE PH.PropertyID = CASE WHEN @propertyId = -999 THEN  PH.PropertyID ELSE @propertyId END
			AND PH.SupplierID = CASE WHEN @supId = -999 THEN PH.SupplierID ELSE @supId END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by PH.CreatedDate desc

		END
	END

	ELSE IF(@type='71')
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT TOP (@TopDocLimit) PH.Id AS id, PoNo +' '+' | '+ CONVERT(varchar(10), DocumentDate, 111) AS text  
			FROM dbo.PoHeaders PH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
			INNER JOIN POCancellationLog PC ON PC.PoHeaderId = PH.Id
			WHERE PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
			AND SupplierID = CASE WHEN @supId = -999 THEN SupplierID ELSE @supId END
			AND DocumentStatus = 'X'
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by CreatedDate desc
		END
		ELSE
		BEGIN
			SELECT  PH.Id AS id, PoNo +' '+' | '+ CONVERT(varchar(10), DocumentDate, 111) AS text  
			FROM dbo.PoHeaders PH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
			INNER JOIN POCancellationLog PC ON PC.PoHeaderId = PH.Id
			WHERE PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
			AND SupplierID = CASE WHEN @supId = -999 THEN SupplierID ELSE @supId END
			AND DocumentStatus = 'X'
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by CreatedDate desc
		END
	END

	ELSE IF(@type='72')
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT DISTINCT  TOP (@TopDocLimit) CH.ID ,TxnNo +' '+' | '+ CONVERT(CHAR(10), TaxnDate, 111)+' '+' | '+ ISNULL(LO.Name,'') AS text 
			FROM CommiRequestHeader CH
			INNER JOIN LOCATIONS LO ON LO.ID = CH.RequestedLocationID
			WHERE CH.PropertyID =CASE WHEN @propertyId = -999 THEN  CH.PropertyID ELSE @propertyId END
			AND CH.RequestedLocationID = CASE WHEN @locationId = -999 THEN CH.RequestedLocationID ELSE @locationId END
			UNION 
			SELECT DISTINCT TOP (@TopDocLimit) CH.ID ,TxnNo +' '+' | '+ CONVERT(CHAR(10), TaxnDate, 111)+' '+' | '+ ISNULL(LO.Name,'') AS text 
			FROM CommiRequestHeader CH
			INNER JOIN LOCATIONS LO ON LO.ID = CH.ProductionLocationID
			WHERE CH.PropertyID =CASE WHEN @propertyId = -999 THEN  CH.PropertyID ELSE @propertyId END
			AND CH.ProductionLocationID = CASE WHEN @locationId = -999 THEN CH.ProductionLocationID ELSE @locationId END
		END
		ELSE
		BEGIN
			SELECT DISTINCT  CH.ID ,TxnNo +' '+' | '+ CONVERT(CHAR(10), TaxnDate, 111)+' '+' | '+ ISNULL(LO.Name,'') AS text 
			FROM CommiRequestHeader CH
			INNER JOIN LOCATIONS LO ON LO.ID = CH.RequestedLocationID
			WHERE CH.PropertyID =CASE WHEN @propertyId = -999 THEN  CH.PropertyID ELSE @propertyId END
			AND CH.RequestedLocationID = CASE WHEN @locationId = -999 THEN CH.RequestedLocationID ELSE @locationId END
			UNION 
			SELECT DISTINCT CH.ID ,TxnNo +' '+' | '+ CONVERT(CHAR(10), TaxnDate, 111)+' '+' | '+ ISNULL(LO.Name,'') AS text 
			FROM CommiRequestHeader CH
			INNER JOIN LOCATIONS LO ON LO.ID = CH.ProductionLocationID
			WHERE CH.PropertyID =CASE WHEN @propertyId = -999 THEN  CH.PropertyID ELSE @propertyId END
			AND CH.ProductionLocationID = CASE WHEN @locationId = -999 THEN CH.ProductionLocationID ELSE @locationId END

		END
	END

	ELSE IF(@type = '9' AND @IsRetail = 0)
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN

			SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,  CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
		ELSE
		BEGIN 
			SELECT  DISTINCT sh.Id AS id,  CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END

	END
	ELSE IF(@type = '9' AND @IsRetail = 1)
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN

			SELECT  DISTINCT TOP (@TopDocLimit) CONCAT(PH.InvHeaderID,PH.LocationID) AS id,CONCAT(PH.InvoiceNo ,' | ' ,CONVERT(varchar(10), PH.BusinessDate, 111))AS text 
			FROM POS_InvoiceHeader PH
			INNER JOIN  @UserWiseLocation UL ON UL.LocID = PH.LocationID
			WHERE PH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE PH.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by CONCAT(PH.InvHeaderID,PH.LocationID) desc
			
		END
		ELSE
		BEGIN 
			SELECT  DISTINCT  CONCAT(PH.InvHeaderID,PH.LocationID) AS id,CONCAT(PH.InvoiceNo ,' | ' ,CONVERT(varchar(10), PH.BusinessDate, 111))AS text 
			FROM POS_InvoiceHeader PH
			INNER JOIN  @UserWiseLocation UL ON UL.LocID = PH.LocationID
			WHERE PH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE PH.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by CONCAT(PH.InvHeaderID,PH.LocationID) desc
		END

	END

	ELSE IF(@type = '3' OR @type = '5' OR @type = '6' OR @type = '13' OR @type = '10' OR @type = '4' OR @type = '7' ) -- 85 Backend Invoice
	BEGIN 
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN

			SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,
			CASE WHEN @type = '85' THEN CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ',SH.TaxInvoiceNumber,' | ',CONVERT(varchar(10), sh.TransactionDate, 111))
			ELSE CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))END AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
		ELSE
		BEGIN 
			SELECT  DISTINCT sh.Id AS id,  CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
		END

	-- Added by Tharuka 2026-08-17 
	ELSE IF( @type = '85') -- 85 Backend Invoice
	BEGIN 
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN

			SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,
			CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ',SH.TaxInvoiceNumber,' | ',CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.InvoiceLocationID
			left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.InvoiceLocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.InvoiceLocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
		ELSE
		BEGIN 
			SELECT  DISTINCT sh.Id AS id,  CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.InvoiceLocationID
			left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.InvoiceLocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.InvoiceLocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
	END
		-------------------------
		--added by Isuru 2026-09-18 87 Franchise Return - same shape as 85 BackEnd Invoice
	ELSE IF( @type = '87')
	BEGIN
		IF(@IsPrintCopyDocLimit =1)
		BEGIN
			SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,
			CONCAT(sh.DocumentNo ,' | ',CONVERT(varchar(10), sh.TransactionDate, 111)) AS text
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.InvoiceLocationID
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END
			AND sh.InvoiceLocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.InvoiceLocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
		ELSE
		BEGIN
			SELECT DISTINCT sh.Id AS id,
			CONCAT(sh.DocumentNo ,' | ',CONVERT(varchar(10), sh.TransactionDate, 111)) AS text
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.InvoiceLocationID
			WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END
			AND sh.InvoiceLocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.InvoiceLocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			order by sh.Id desc
		END
	END

	ELSE  IF(@type = '1'  OR @type = '11' OR @type = '86')
	BEGIN 
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT  TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111) +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseDeparetment UD ON UD.DepID = RH.DepartmentID
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
			AND UD.DepID =  CASE WHEN @deptId = -999 THEN UD.DepID  ELSE @deptId  END
			ORDER BY RH.id DESC
		END
		ELSE
		BEGIN
			SELECT  RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111) +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseDeparetment UD ON UD.DepID = RH.DepartmentID
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
			AND UD.DepID =  CASE WHEN @deptId = -999 THEN UD.DepID  ELSE @deptId  END
			ORDER BY RH.id DESC
		END
	END
	ELSE  IF(@type = '14')
	BEGIN 
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111) AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.LocationID
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			ORDER BY RH.id DESC
		END
		ELSE
		BEGIN
			SELECT  RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111) AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.LocationID
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			ORDER BY RH.id DESC
		END
	END
	ELSE  IF(@type = '8' )
	BEGIN 
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT distinct  TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111)  +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.TransferLocation
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.TransferLocation = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.TransferLocation END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			union
			SELECT distinct  TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111)  +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.LocationID
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			ORDER BY RH.id DESC
		END
		ELSE
		BEGIN
			SELECT distinct  RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111)  +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.TransferLocation
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.TransferLocation = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.TransferLocation END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			union
			SELECT distinct  RH.Id AS id, RH.DocumentNo +' '+' | '+ CONVERT(varchar(10), RH.RequestDate, 111)  +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
			FROM dbo.RequestHeaders RH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.LocationID
			WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
			AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
			AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			ORDER BY RH.id DESC
		END
	END

	ELSE IF(@type ='12')
	BEGIN 
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN

			SELECT   TOP (@TopDocLimit) sh.Id AS id,  CONCAT(SH2.DocumentNo,' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			--INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id
			INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id and sh2.DocumentNo = sh.ReferenceNo
			WHERE sh.TransactionID = @type AND  sh.PropertyID = CASE WHEN @propertyId = -999 THEN  sh.PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			UNION ALL 
			SELECT  TOP (@TopDocLimit)  sh.Id AS id,  CONCAT(SH2.DocumentNo,' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			INNER JOIN RequestHeaders rh on sh.ReferenceID = rh.Id
			--INNER JOIN StockTransactionHeaders SH2 ON SH2.ReferenceID = rh.Id
			INNER JOIN StockTransactionHeaders SH2 ON SH2.ReferenceID = rh.Id and sh2.ReferenceNo =  sh.ReferenceNo and sh2.TransactionType='TO'
			WHERE sh.TransactionID = @type AND  sh.PropertyID = CASE WHEN @propertyId = -999 THEN  sh.PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND SH2.DocumentNo <> SH.DocumentNo
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			ORDER BY id DESC --2025-01-24 Modify by Nivesh for getting reference for Direct TransferNote
		END
		ELSE
		BEGIN
			SELECT   sh.Id AS id,  CONCAT(SH2.DocumentNo,' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			--INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id
			INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id and sh2.DocumentNo = sh.ReferenceNo
			WHERE sh.TransactionID = @type AND  sh.PropertyID = CASE WHEN @propertyId = -999 THEN  sh.PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			UNION ALL 
			SELECT    sh.Id AS id,  CONCAT(SH2.DocumentNo,' - ',sh.DocumentNo ,' | ' ,CONVERT(varchar(10), sh.TransactionDate, 111))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
			FROM dbo.StockTransactionHeaders sh
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
			INNER JOIN RequestHeaders rh on sh.ReferenceID = rh.Id
			--INNER JOIN StockTransactionHeaders SH2 ON SH2.ReferenceID = rh.Id
			INNER JOIN StockTransactionHeaders SH2 ON SH2.ReferenceID = rh.Id and sh2.ReferenceNo =  sh.ReferenceNo and sh2.TransactionType='TO'
			WHERE sh.TransactionID = @type AND  sh.PropertyID = CASE WHEN @propertyId = -999 THEN  sh.PropertyID ELSE @propertyId END 
			AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
			AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
			AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
			AND SH2.DocumentNo <> SH.DocumentNo
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
			ORDER BY id DESC --2025-01-24 Modify by Nivesh for getting reference for Direct TransferNote
		END
	END

	--ELSE IF (@type = '9 ')
	--BEGIN
	--SELECT   IH.Id AS id, IH.InvoiceNo +' '+' | '+ FORMAT(IH.CreatedDate, 'yyyy/MM/dd')  AS text 
	--FROM dbo.InvoiceHeaders IH
	--INNER JOIN @UserWiseLocation UL ON UL.LocID = IH.Location
	--WHERE   IH.PropertyID = CASE WHEN @propertyId = -999 THEN  IH.PropertyID ELSE @propertyId END
	--AND IH.Location = CASE WHEN @locationId <> -999 THEN @locationId ELSE IH.Location END
	--AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	--end

	ELSE IF (@type = '70')
	BEGIN
		IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
		BEGIN
			SELECT  TOP (@TopDocLimit) SIH.Id AS id, SIH.DocNo +' '+' | '+CONVERT(CHAR(10), SIH.SpotCheckDate, 111) AS text 
			FROM StockSpotCheckHeader SIH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SIH.LocationID
			WHERE   SIH.PropertyID = CASE WHEN @propertyId = -999 THEN  SIH.PropertyID ELSE @propertyId END
			AND SIH.LocationID = CASE WHEN @locationId = -999 THEN SIH.LocationID ELSE @locationId END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
		END
		ELSE
		BEGIN
			SELECT   SIH.Id AS id, SIH.DocNo +' '+' | '+ CONVERT(CHAR(10), SIH.SpotCheckDate, 111)  AS text 
			FROM StockSpotCheckHeader SIH
			INNER JOIN @UserWiseLocation UL ON UL.LocID = SIH.LocationID
			WHERE   SIH.PropertyID = CASE WHEN @propertyId = -999 THEN  SIH.PropertyID ELSE @propertyId END
			AND SIH.LocationID = CASE WHEN @locationId = -999 THEN SIH.LocationID ELSE @locationId END
			AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
		END
	end

		ELSE IF (@type = '74')
		BEGIN
			IF(@IsPrintCopyDocLimit =1) -- LIMIT DOCUMENT DISPLAYING FOR (@TopDocLimit) THEN SEARCH WITH API
			BEGIN
				SELECT DISTINCT TOP (@TopDocLimit) BH.Id AS id,CONCAT(BH.DocNo,' | ' ,CONVERT(CHAR(10), BH.CreatedDate, 111))AS text 
				FROM [dbo].[BatchTransactionHeader] BH
				WHERE ISNULL(BH.SupplierID,-999) = CASE WHEN @supId = -999 THEN ISNULL(BH.SupplierID,-999) ELSE @supId END
				AND ISNULL(BH.LocationID,-999) = CASE WHEN @locationId = -999 THEN ISNULL(BH.LocationID,-999) ELSE @locationId END
				AND ISNULL(BH.PropertyID,-999) = CASE WHEN @propertyId = -999 THEN ISNULL(BH.PropertyID,-999) ELSE @propertyId END
				ORDER BY text
			END
			ELSE
			BEGIN
				SELECT DISTINCT BH.Id AS id,CONCAT(BH.DocNo,' | ' ,CONVERT(CHAR(10), BH.CreatedDate, 111))AS text 
				FROM [dbo].[BatchTransactionHeader] BH
				WHERE ISNULL(BH.SupplierID,-999) = CASE WHEN @supId = -999 THEN ISNULL(BH.SupplierID,-999) ELSE @supId END
				AND ISNULL(BH.LocationID,-999) = CASE WHEN @locationId = -999 THEN ISNULL(BH.LocationID,-999) ELSE @locationId END
				AND ISNULL(BH.PropertyID,-999) = CASE WHEN @propertyId = -999 THEN ISNULL(BH.PropertyID,-999) ELSE @propertyId END
				ORDER BY text
			END
		END

		--added by isuru 2026-10-30
		ELSE IF (@type = '88')
		BEGIN
			SELECT TOP (CASE WHEN @IsPrintCopyDocLimit = 1 THEN @TopDocLimit ELSE 2147483647 END)
				SEH.ID AS id,
				CONCAT(SEH.DocumentNumber, ' | ', FORMAT(SEH.CreatedDate, 'yyyy/MM/dd'), ' | ', S.Name, ' | ',
				CASE WHEN SEH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END) AS text
			FROM dbo.SupplierEvaluationHeader SEH
			INNER JOIN dbo.Suppliers S ON S.ID = SEH.SupplierID
			WHERE SEH.PropertyID = CASE WHEN @propertyId = -999 THEN SEH.PropertyID ELSE @propertyId END
			AND SEH.SupplierID = CASE WHEN @supId = -999 THEN SEH.SupplierID ELSE @supId END
			AND SEH.DocumentNumber IS NOT NULL
			ORDER BY SEH.ID DESC
		END
		--End

		
	END

GO

