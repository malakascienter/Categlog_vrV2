
-- [dbo].[SP_PrintLoadDocument_SearchKeyWord] 1,3,-999,-999,-999,'ga',4168

CREATE PROCEDURE [dbo].[SP_PrintLoadDocument_SearchKeyWord]
	@propertyId INT,
	@type VARCHAR(max),
	@deptId INT =-999,
	@supId INT =-999,
	@locationId INT= -999,
	@SearchKeyWord VARCHAR(MAX),
	@userid INT
AS
BEGIN
SET @SearchKeyWord = LTRIM(RTRIM(@SearchKeyWord))

DECLARE @isPOApprovalForPrintPreview BIT,@TopDocLimit INT;

	SET @TopDocLimit = 2000;

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



--IF(@type='2')
--BEGIN
--SELECT TOP (100) Id AS id, PoNo +' '+' | '+ CONVERT(VARCHAR,DocumentDate,31) AS text FROM dbo.PoHeaders WHERE PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
--AND SupplierID = CASE WHEN @supId = -999 THEN SupplierID ELSE @supId END  
--AND PoNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
--order by CreatedDate desc
--END

IF(@type='2' and @isPOApprovalForPrintPreview = 1 )
BEGIN
	SELECT  TOP (@TopDocLimit) PH.Id AS id,  PH.PoNo +' '+' | '+ FORMAT( PH.DocumentDate, 'yyyy/MM/dd') +' '+' | '+ CASE WHEN PH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text  
	FROM dbo.PoHeaders PH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
	WHERE  PH.PropertyID = CASE WHEN @propertyId = -999 THEN   PH.PropertyID ELSE @propertyId END
	AND  PH.SupplierID = CASE WHEN @supId = -999 THEN  PH.SupplierID ELSE @supId END
	and IsApproved = 1 
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND PoNo LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%'
	order by PH.CreatedDate desc		
END

IF(@type='2' and @isPOApprovalForPrintPreview = 0 )
BEGIN
	SELECT TOP (@TopDocLimit) PH.Id AS id, PH.PoNo +' '+' | '+ FORMAT(PH.DocumentDate, 'yyyy/MM/dd') +' '+' | '+ CASE WHEN PH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text  
	FROM dbo.PoHeaders PH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
	WHERE PH.PropertyID = CASE WHEN @propertyId = -999 THEN  PH.PropertyID ELSE @propertyId END
	AND PH.SupplierID = CASE WHEN @supId = -999 THEN PH.SupplierID ELSE @supId END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND PoNo LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%'
	order by PH.CreatedDate desc
END

ELSE IF(@type='71') -- PO CANCELLATION
BEGIN
	SELECT TOP (@TopDocLimit) PH.Id AS id, PoNo +' '+' | '+ FORMAT(DocumentDate, 'yyyy/MM/dd') AS text  
	FROM dbo.PoHeaders PH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = PH.LocationID
	INNER JOIN POCancellationLog PC ON PC.PoHeaderId = PH.Id
	WHERE PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
	AND SupplierID = CASE WHEN @supId = -999 THEN SupplierID ELSE @supId END
	AND DocumentStatus = 'X'
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND PoNo LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%'
	order by CreatedDate desc	
END

ELSE IF(@type='72')
BEGIN		
	SELECT DISTINCT  TOP (@TopDocLimit) CH.ID ,TxnNo +' '+' | '+ FORMAT(TaxnDate, 'yyyy/MM/dd')+' '+' | '+ ISNULL(LO.Name,'') AS text 
	FROM CommiRequestHeader CH
	INNER JOIN LOCATIONS LO ON LO.ID = CH.RequestedLocationID
	WHERE CH.PropertyID =CASE WHEN @propertyId = -999 THEN  CH.PropertyID ELSE @propertyId END
	AND CH.RequestedLocationID = CASE WHEN @locationId = -999 THEN CH.RequestedLocationID ELSE @locationId END
	AND (TxnNo LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%'
	OR ISNULL(LO.Name,'') LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%')
	
	UNION 
	
	SELECT DISTINCT TOP (@TopDocLimit) CH.ID ,TxnNo +' '+' | '+ FORMAT(TaxnDate, 'yyyy/MM/dd')+' '+' | '+ ISNULL(LO.Name,'') AS text 
	FROM CommiRequestHeader CH
	INNER JOIN LOCATIONS LO ON LO.ID = CH.ProductionLocationID
	WHERE CH.PropertyID =CASE WHEN @propertyId = -999 THEN  CH.PropertyID ELSE @propertyId END
	AND CH.ProductionLocationID = CASE WHEN @locationId = -999 THEN CH.ProductionLocationID ELSE @locationId END
	AND (TxnNo LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%'
	OR ISNULL(LO.Name,'') LIKE '%'+CONVERT(varchar(200), @SearchKeyWord)+'%')	
END

ELSE IF(@type = '3' OR @type = '5' OR @type = '6' OR @type = '13' OR @type = '10' OR @type = '4' OR @type = '7' OR @type = '9' )
BEGIN 
	SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,  CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ' ,FORMAT(sh.TransactionDate, 'yyyy/MM/dd'))AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
	FROM dbo.StockTransactionHeaders sh
	INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
	left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
	WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
	AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
	AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
	AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND ( sh.DocumentNo LIKE '%' + @SearchKeyWord + '%'
     OR ISNULL(gl.ApprovalDocNo, '') LIKE '%' + @SearchKeyWord + '%')
	order by sh.Id desc
		
END





--ELSE IF(@type = '3' OR @type = '5' OR @type = '6' OR @type = '13' OR @type = '10' OR @type = '4' OR @type = '7')
--BEGIN 
--	SELECT TOP (100) Id AS id, DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text,CreatedDate FROM dbo.StockTransactionHeaders WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END 
--	AND DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE DepartmentID END 
--	AND SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE SupplierID END
--	AND LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE LocationID END
--	AND DocumentNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
--	order by CreatedDate desc
--	END

ELSE  IF(@type = '1'  OR @type = '11' )
BEGIN 
	SELECT  TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ FORMAT(RH.RequestDate, 'yyyy/MM/dd') +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
	FROM dbo.RequestHeaders RH
	INNER JOIN @UserWiseDeparetment UD ON UD.DepID = RH.DepartmentID
	WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
	AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
	AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
	AND UD.DepID =  CASE WHEN @deptId = -999 THEN UD.DepID  ELSE @deptId  END
	AND DocumentNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
	ORDER BY RH.id DESC
		
END

ELSE  IF(@type = '14')
BEGIN 
	SELECT TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ FORMAT(RH.RequestDate, 'yyyy/MM/dd') AS text 
	FROM dbo.RequestHeaders RH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.LocationID
	WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
	AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
	AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND DocumentNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
	ORDER BY RH.id DESC
		
END

ELSE  IF(@type = '8' )
BEGIN 		
	SELECT distinct  TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ FORMAT(RH.RequestDate, 'yyyy/MM/dd')  +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
	FROM dbo.RequestHeaders RH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.TransferLocation
	WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
	AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
	AND RH.TransferLocation = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.TransferLocation END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND DocumentNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
	
	union
	
	SELECT distinct  TOP (@TopDocLimit) RH.Id AS id, RH.DocumentNo +' '+' | '+ FORMAT(RH.RequestDate, 'yyyy/MM/dd')  +' '+' | '+ CASE WHEN RH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END  AS text 
	FROM dbo.RequestHeaders RH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = RH.LocationID
	WHERE RH.TransactionTypeCode = @type AND  RH.PropertyID = CASE WHEN @propertyId = -999 THEN  RH.PropertyID ELSE @propertyId END
	AND RH.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE RH.DepartmentID END 
	AND RH.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE RH.LocationID END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND DocumentNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
	ORDER BY RH.id DESC
		
END


ELSE IF(@type ='12')
BEGIN 		
	SELECT   TOP (@TopDocLimit) sh.Id AS id,  CONCAT(SH2.DocumentNo,' - ',sh.DocumentNo ,' | ' ,FORMAT(sh.TransactionDate, 'yyyy/MM/dd') )AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
	FROM dbo.StockTransactionHeaders sh
	INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.LocationID
	--INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id
	INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id and sh2.DocumentNo = sh.ReferenceNo
	WHERE sh.TransactionID = @type AND  sh.PropertyID = CASE WHEN @propertyId = -999 THEN  sh.PropertyID ELSE @propertyId END 
	AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END 
	AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
	AND sh.LocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.LocationID END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND ( sh.DocumentNo LIKE '%' + @SearchKeyWord + '%'
     OR ISNULL(SH2.DocumentNo, '') LIKE '%' + @SearchKeyWord + '%')
	UNION ALL 
	
	SELECT  TOP (@TopDocLimit)  sh.Id AS id,  CONCAT(SH2.DocumentNo,' - ',sh.DocumentNo ,' | ' ,FORMAT(sh.TransactionDate, 'yyyy/MM/dd') )AS text  --DocumentNo+' '+' | '+ CONVERT(VARCHAR,CreatedDate,31) AS text 
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
	AND ( sh.DocumentNo LIKE '%' + @SearchKeyWord + '%'
     OR ISNULL(SH2.DocumentNo, '') LIKE '%' + @SearchKeyWord + '%')
	ORDER BY id DESC --2025-01-24 Modify by Nivesh for getting reference for Direct TransferNote
		
END

ELSE IF (@type = '70')
BEGIN		
	SELECT  TOP (@TopDocLimit) SIH.Id AS id, SIH.DocNo +' '+' | '+ FORMAT(SIH.SpotCheckDate, 'yyyy/MM/dd')  AS text 
	FROM StockSpotCheckHeader SIH
	INNER JOIN @UserWiseLocation UL ON UL.LocID = SIH.LocationID
	WHERE   SIH.PropertyID = CASE WHEN @propertyId = -999 THEN  SIH.PropertyID ELSE @propertyId END
	AND SIH.LocationID = CASE WHEN @locationId = -999 THEN SIH.LocationID ELSE @locationId END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND SIH.DocNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
		
END

ELSE IF (@type = '74')
BEGIN
	SELECT DISTINCT TOP (@TopDocLimit) BH.Id AS id,CONCAT(BH.DocNo,' | ' ,FORMAT(BH.CreatedDate, 'yyyy/MM/dd'))AS text 
	FROM [dbo].[BatchTransactionHeader] BH
	WHERE ISNULL(BH.SupplierID,-999) = CASE WHEN @supId = -999 THEN ISNULL(BH.SupplierID,-999) ELSE @supId END
	AND ISNULL(BH.LocationID,-999) = CASE WHEN @locationId = -999 THEN ISNULL(BH.LocationID,-999) ELSE @locationId END
	AND ISNULL(BH.PropertyID,-999) = CASE WHEN @propertyId = -999 THEN ISNULL(BH.PropertyID,-999) ELSE @propertyId END
	AND BH.DocNo LIKE '%'+CONVERT(varchar(10), @SearchKeyWord)+'%'
	ORDER BY text
	
END

--added by Isuru 2026-09-18 85 BackEnd Invoice - this type had no branch here, so typing in the document
--box returned nothing even though SP_PrintLoadDocument lists it. Same columns and filters as that branch.
ELSE IF (@type = '85')
BEGIN
	SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,
	CONCAT(ISNULL(gl.ApprovalDocNo,''),' - ',sh.DocumentNo ,' | ',SH.TaxInvoiceNumber,' | ',FORMAT(sh.TransactionDate, 'yyyy/MM/dd')) AS text
	FROM dbo.StockTransactionHeaders sh
	INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.InvoiceLocationID
	left join [dbo].[GRNApprovalLog] gl on gl.StockTransactionHeaderID = sh.Id
	WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
	AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END
	AND sh.SupplierID = CASE WHEN @supId <>-999 THEN @supId ELSE sh.SupplierID END
	AND sh.InvoiceLocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.InvoiceLocationID END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND ( sh.DocumentNo LIKE '%' + @SearchKeyWord + '%'
	  OR ISNULL(sh.TaxInvoiceNumber,'') LIKE '%' + @SearchKeyWord + '%'
	  OR ISNULL(gl.ApprovalDocNo, '') LIKE '%' + @SearchKeyWord + '%')
	order by sh.Id desc

END

--added by Isuru 2026-09-18 87 Franchise Return (BR) - searchable the same way, matching its branch in
--SP_PrintLoadDocument. No GRNApprovalLog / TaxInvoiceNumber: a 'BR' has no approval flow and no tax invoice number.
ELSE IF (@type = '87')
BEGIN
	SELECT DISTINCT TOP (@TopDocLimit) sh.Id AS id,
	CONCAT(sh.DocumentNo ,' | ',FORMAT(sh.TransactionDate, 'yyyy/MM/dd')) AS text
	FROM dbo.StockTransactionHeaders sh
	INNER JOIN @UserWiseLocation UL ON UL.LocID = SH.InvoiceLocationID
	WHERE TransactionID = @type AND  PropertyID = CASE WHEN @propertyId = -999 THEN  PropertyID ELSE @propertyId END
	AND sh.DepartmentID = CASE WHEN @deptId <>-999 THEN @deptId ELSE sh.DepartmentID END
	AND sh.InvoiceLocationID = CASE WHEN @locationId <> -999 THEN @locationId ELSE sh.InvoiceLocationID END
	AND UL.LocID =  CASE WHEN @locationId = -999 THEN UL.LocID  ELSE @locationId  END
	AND sh.DocumentNo LIKE '%' + @SearchKeyWord + '%'
	order by sh.Id desc

END



--added by isuru 2026-10-30 Supplier Grading (SGR)
ELSE IF (@type = '88')
BEGIN
	SELECT TOP (@TopDocLimit)
		   SEH.ID AS id,
		   CONCAT(SEH.DocumentNumber, ' | ', FORMAT(SEH.CreatedDate, 'yyyy/MM/dd'), ' | ', S.Name, ' | ',
		   CASE WHEN SEH.IsApproved = 1 THEN 'Approved' ELSE 'Pending' END) AS text
	FROM dbo.SupplierEvaluationHeader SEH
	INNER JOIN dbo.Suppliers S ON S.ID = SEH.SupplierID
	WHERE SEH.PropertyID = CASE WHEN @propertyId = -999 THEN SEH.PropertyID ELSE @propertyId END
	AND SEH.SupplierID = CASE WHEN @supId = -999 THEN SEH.SupplierID ELSE @supId END
	AND SEH.DocumentNumber IS NOT NULL
	AND (SEH.DocumentNumber LIKE '%' + @SearchKeyWord + '%'
		 OR S.Name LIKE '%' + @SearchKeyWord + '%')
	ORDER BY SEH.ID DESC
END


END

GO

