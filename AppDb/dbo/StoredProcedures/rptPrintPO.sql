

-- [dbo].[rptPrintPO] 707,5836
CREATE  PROCEDURE [dbo].[rptPrintPO]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS


DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId NVARCHAR(MAX)
)
declare @IsCentralLogin BIT
SELECT @IsCentralLogin = IsCentralLogin FROM Companies C
inner join PoHeaders H ON h.PropertyID = c.CompanyID
WHERE H.Id= @StockTxnID

		print '03 A'

		IF(@IsCentralLogin = 1)
		BEGIN
		print 'P'
			 		
			INSERT INTO @UserData
			SELECT Id, UserName, EmpNumber
			FROM [dbo].[CentralUsers]
			

		END
		ELSE
		BEGIN
		print 'Q'

			INSERT INTO @UserData
			SELECT Id, UserName,EmployeeId
			FROM UserMasters

		END


DECLARE @DcoumentStatus VARCHAR,
		@AdditionalCharge DECIMAL(18,2)


		select @AdditionalCharge =sum(ChargeAmount)
		from PoHeaders PO
		INNER JOIN POwiseCharges PW ON PO.Id = PW.POHeaderID
		where PO.Id=@StockTxnID

		---ADDED BY ISURU
		DECLARE @CreatedUserName VARCHAR(500),
				@ApprovedUserName VARCHAR(500),	
				@ReferenceNO VARCHAR(MAX)
				

		SELECT @CreatedUserName = STRING_AGG(U.UserName, ', ')  
		FROM PoHeaders PH
		left JOIN @UserData U ON PH.UserProfileID = U.Id 
		WHERE (PH.ID = @StockTxnID)

		--SELECT @ApprovedUserName =STRING_AGG(U.UserName, ' | ')  
		--FROM PoHeaders PH
		--LEFT JOIN ApprovalLogs AP ON PH.ID = AP.TransactionHeaderID
		--left JOIN @UserData U ON AP.ApprovalUserID = U.Id 
		--WHERE (PH.ID = @StockTxnID)
		
		--SELECT @ApprovedUserName = STRING_AGG( ISNULL(CU.UserName, ''), ' | ')  
		--FROM PoHeaders PH
		--INNER JOIN ApprovalLogs AP ON PH.Id = AP.TransactionHeaderID
		--INNER JOIN @UserData CU ON CU.Id =  AP.ApprovalUserID
		--WHERE PH.Id = @StockTxnID AND AP.IsComplete=1 --AND AP.TransactionID=2
		--GROUP BY CU.UserName


		SELECT @ApprovedUserName= STUFF((
		SELECT DISTINCT ' | ' + CU.UserName + ' (' +FORMAT(AP.ApprovalDate, 'yyyy-MM-dd HH:mm') + ')'
		FROM PoHeaders PH
		INNER JOIN ApprovalLogs AP ON PH.Id = AP.TransactionHeaderID
		INNER JOIN CentralUsers CU ON CU.Id = AP.ApprovalUserID
		WHERE PH.Id = @StockTxnID AND AP.IsComplete=1 AND AP.TransactionID=2
		FOR XML PATH('')), 1, 1, '') 
		---END

		SELECT @ReferenceNO =  STUFF((
		SELECT DISTINCT ' | ' + ISNULL(RH.DocumentNo,'')+' | ' 
		FROM PoHeaders PH
		INNER JOIN PoWisePRs PW ON PH.Id = PW.PoHeaderID
		INNER JOIN RequestHeaders RH ON RH.Id = PW.RequestHeaderID
		WHERE PH.ID =@StockTxnID
		FOR XML PATH('')), 1, 1, '') 


		--added by Isuru 2023-07-27
		DECLARE @PropertyID INT, @DeliveryTelNo VARCHAR(15), @DeliveyEmail VARCHAR(MAX), @DeliveryContactPerson VARCHAR(MAX),	@POLocationID INT,@DeliveryAddress VARCHAR(MAX)
		SELECT @PropertyID = h.PropertyID,@POLocationID = H.LocationID,@DeliveryAddress = DeliveryAddressID
		FROM PoHeaders H 
		WHERE H.Id= @StockTxnID

		
IF EXISTS( SELECT 1
		FROM DeliveryAddressDetails
		WHERE PropertyID = @PropertyID AND TRIM(Address) = TRIM(@DeliveryAddress) )
BEGIN

		SELECT @DeliveryTelNo =trim(Telephone1),@DeliveyEmail = Email, @DeliveryContactPerson = trim(ContactPerson)
		FROM DeliveryAddressDetails
		WHERE PropertyID = @PropertyID AND TRIM(Address) = TRIM(@DeliveryAddress)
 

END
ELSE
BEGIN

		SELECT TOP(1) @DeliveryTelNo =trim(Telephone1),@DeliveyEmail = Email, @DeliveryContactPerson = trim(ContactPerson)
		FROM DeliveryAddressDetails
		WHERE PropertyID = @PropertyID --AND TRIM(Address) = TRIM(@DeliveryAddress)
		ORDER BY DeliveryAddressID ASC
 

END


		--end


		--Added by Isuru 2024-01-31

		DECLARE @ProcurementName VARCHAR(200)

		SELECT @ProcurementName=isnull(US.UserName,'')
		FROM UserWiseApproveLevels UP
		INNER JOIN @UserData US ON UP.UserProfileId = US.Id
		WHERE PropertyId= @PropertyID  
		AND LocationId = @POLocationID
		AND TransactionTypeID = 2
		AND ApproveLevelID=5
		--end

		DECLARE @TaxTotal  DECIMAL(18,6)
		SELECT @TaxTotal = SUM(POwiseTaxes.TaxAmount)
		FROM PoDetails INNER JOIN
        PoHeaders ON PoDetails.PoHeaderID = PoHeaders.ID 
		INNER JOIN POwiseTaxes ON POwiseTaxes.PODetailID = PoDetails.Id
		where		(PoHeaders.ID = @StockTxnID)

		DECLARE @RejectReason VARCHAR(MAX)

		
		SELECT @RejectReason = STRING_AGG(NULLIF(REMARKS,''), CHAR(10))
		FROM (
		SELECT  ISNULL(REMARKS,'') AS REMARKS
		FROM ApprovalLogs
		WHERE TransactionID = 2
		AND TransactionHeaderID = @StockTxnID

		UNION ALL
		SELECT ISNULL(RejectedReason,'') AS REMARKS
		FROM CommonTransactionStatusLog
		WHERE TransactionHeaderID = @StockTxnID
		AND TransactionID = 2
		AND Status  = 'X'
		) AS X;

		
		

SELECT        PoHeaders.Id, PoHeaders.PoHeaderID, PoHeaders.LocationID, PoHeaders.PoNo, PoHeaders.SupplierID, PoHeaders.DocumentDate, PoHeaders.Remarks, PoHeaders.CreatedUserID, PoHeaders.LastModUserID, 
                         PoHeaders.DeliveryDate, trim(PoHeaders.DeliveryAddressID)+'. '+ '                    (Contact: '+@DeliveryContactPerson+' '+ @DeliveryTelNo+')' as DeliveryAddressID , (PoHeaders.NetTotal+isnull(@AdditionalCharge,0))as NetTotal, PoHeaders.GrossTotal, PoHeaders.TotalDiscount,@TaxTotal AS TaxTotal,-- PoHeaders.TaxTotal,
						 PoDetails.StockItemID, PoDetails.UnitID, PoDetails.UnitPrice, 
                         PoDetails.RequestedQuantity, PoDetails.ApprovedQuantity, PoDetails.ReceivedQuantity, StockItemHeaders.StockItemCode,
						 StockItemHeaders.Name, 
						  --CONCAT(StockItemHeaders.Name,' (',ISNULL(RH.DocumentNo,''),')') Name,
						 Suppliers.Name AS SuppName, Suppliers.Address1, 
                         Companies.Telephone1, Companies.Telephone2, Companies.FaxNo, Companies.Email, Units.Name AS Unit, PoDetails.ApprovedQuantity*PoDetails.UnitPrice as TotalVal,Companies.TaxRegistrationNumber1,
						 Companies.Name AS company,
						 Companies.Address1+' '+Companies.Address2+' '+Companies.Address3 AS CompanyAddress,
						 CASE  WHEN PoHeaders.DocumentStatus = 'X' THEN 'CANCELLED' WHEN PoHeaders.IsApproved = 0 THEN 'PENDING'  WHEN PoHeaders.IsApproved = 1 THEN 'Approved'   END as DocumentStatus,
						-- CASE  WHEN PoHeaders.DocumentStatus = 'P' THEN 'PENDING'  WHEN PoHeaders.DocumentStatus = 'X' THEN 'CANCELLED'  WHEN PoHeaders.DocumentStatus = 'C' THEN 'ACCEPTED' END as DocumentStatus,
						 CASE  WHEN PoHeaders.Isprint = 1 THEN 'DUPLICATE'  WHEN PoHeaders.Isprint = 0 THEN 'ORIGINAL' END as Isprint,@AdditionalCharge ChargeAmount
						 ,@CreatedUserName CreatedUserName,@ApprovedUserName ApprovedUserName, PoHeaders.PropertyID,Companies.TaxRegistrationNumber1 CompanyTaxNumber 
						 ,Locations.Name locationName, Suppliers.Code SuppCode, Suppliers.Telephone1 AS supTelno
						 ,@DeliveryTelNo AS DeliveryTelNo,@DeliveyEmail AS DeliveyEmail,@DeliveryContactPerson AS DeliveryContactPerson
						 ,CASE WHEN PoHeaders.IsApproved=1 THEN @ProcurementName ELSE '-' END AS ProcurementName
						 ,StockItemHeaders.Remarks 'ItemRemark',
						 Suppliers.Remarks 'SupplierRemark'
						 ,PoDetails.Remarks 'PoItemRemarks'
						 ,CASE WHEN LOCATIONS.ApplyDailyMarketProcess =1 THEN 'SHOW' ELSE '' END AS IsServicePO
						 , ISNULL(@ReferenceNo,'Direct PO') ReferenceNO
						 ,@RejectReason AS RejectReason
FROM            PoDetails INNER JOIN
                         PoHeaders ON PoDetails.PoHeaderID = PoHeaders.ID 
						 --INNER JOIN PoWisePRs ON PoHeaders.ID = PoWisePRs.PoHeaderID AND PoDetails.PoHeaderID = PoWisePRs.PoHeaderID AND PoDetails.StockItemID = PoWisePRs.StockItemID
						 INNER JOIN StockItemHeaders ON PoDetails.StockItemID = StockItemHeaders.Id INNER JOIN
                         Locations ON PoHeaders.LocationID = Locations.Id INNER JOIN
                         Companies ON Locations.CompanyID = Companies.CompanyID INNER JOIN
                         Units ON PoDetails.UnitID = Units.Id INNER JOIN
                         Suppliers ON PoHeaders.SupplierID = Suppliers.ID
						-- LEFT JOIN RequestHeaders RH ON PoWisePRs.RequestHeaderID = RH.Id
				       --  LEFT JOIN ApprovalLogs AL ON PoHeaders.Id = AL.TransactionHeaderID
where		(PoHeaders.ID = @StockTxnID)
--where		(PoHeaders.ID = 64981)
--select * from PoHeaders where (PoHeaders.ID = 64981)

--updating IsPrint after View
UPDATE PoHeaders
SET Isprint =1
WHERE PoHeaders.ID = @StockTxnID

GO

