

-- [dbo].[rptPrintCancelPO] 44,1

CREATE  PROCEDURE [dbo].[rptPrintCancelPO]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS


DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId INT
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
				@ApprovedUserName VARCHAR(500)
				

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
		SELECT DISTINCT ' | ' + ISNULL(CU.UserName,'')
		FROM PoHeaders PH
		INNER JOIN ApprovalLogs AP ON PH.Id = AP.TransactionHeaderID
		INNER JOIN CentralUsers CU ON CU.Id = AP.ApprovalUserID
		WHERE PH.Id = @StockTxnID AND AP.IsComplete=1 AND AP.TransactionID=2
		FOR XML PATH('')), 1, 1, '') 
		---END


		--added by Isuru 2023-07-27
		DECLARE @PropertyID INT, @DeliveryTelNo VARCHAR(15), @DeliveyEmail VARCHAR(MAX), @DeliveryContactPerson VARCHAR(MAX),	@POLocationID INT
		SELECT @PropertyID = h.PropertyID,@POLocationID = H.LocationID
		FROM PoHeaders H 
		WHERE H.Id= @StockTxnID

		SELECT @DeliveryTelNo =Telephone1,@DeliveyEmail = Email, @DeliveryContactPerson = ContactPerson
		FROM DeliveryAddressDetails
		WHERE PropertyID = @PropertyID

		--end


		--Added by Isuru 2024-01-31

		DECLARE @ProcurementName VARCHAR(200)

		SELECT @ProcurementName=isnull(US.UserName,'')
		FROM UserWiseApproveLevels UP
		INNER JOIN @UserData US ON UP.UserProfileId = US.Id
		WHERE PropertyId= @PropertyID  
		AND LocationId = @POLocationID
		AND TransactionTypeID = 2
		AND ApproveLevelID=7
		--end


		--Added by Isuru 2024-05-14
		DECLARE @ReferenceNo VARCHAR(MAX)
		SELECT @ReferenceNo= STUFF((
		SELECT DISTINCT ' | ' + ISNULL(RH.DocumentNo,'')
		FROM POHEADERS PH
		INNER JOIN POWISEPRS PW ON PH.ID = PW.PoheaderID
		INNER JOIN RequestHeaders RH on RH.ID = PW.RequestHeaderID
		WHERE PH.Id=@StockTxnID
		FOR XML PATH('')), 1, 1, '') 
		--End

		

SELECT        PoHeaders.Id, PoHeaders.PoHeaderID, PoHeaders.LocationID, PoHeaders.PoNo, PoHeaders.SupplierID, PoHeaders.DocumentDate, PoHeaders.Remarks, PoHeaders.CreatedUserID, PoHeaders.LastModUserID, 
                         PoHeaders.DeliveryDate, Locations.DeliveryAddress DeliveryAddressID, (PoHeaders.NetTotal+isnull(@AdditionalCharge,0))as NetTotal, PoHeaders.GrossTotal, PoHeaders.TotalDiscount, PoHeaders.TaxTotal, PoDetails.StockItemID, PoDetails.UnitID, PoDetails.UnitPrice, 
                         PoDetails.RequestedQuantity, (PoDetails.ApprovedQuantity- PoDetails.ReceivedQuantity) Quantity, StockItemHeaders.StockItemCode, StockItemHeaders.Name, Suppliers.Name AS SuppName, Suppliers.Address1, 
                         Companies.Telephone1, Companies.Telephone2, Companies.FaxNo, Locations.FirstEmail Email, Units.Name AS Unit, PoDetails.ApprovedQuantity*PoDetails.UnitPrice as TotalVal,Companies.TaxRegistrationNumber1,
						 Companies.Name AS company,
						 CASE  WHEN PoHeaders.DocumentStatus = 'X' THEN 'CANCELLED' WHEN PoHeaders.IsApproved = 0 THEN 'PENDING'  WHEN PoHeaders.IsApproved = 1 THEN 'Approved'   END as DocumentStatus,
						-- CASE  WHEN PoHeaders.DocumentStatus = 'P' THEN 'PENDING'  WHEN PoHeaders.DocumentStatus = 'X' THEN 'CANCELLED'  WHEN PoHeaders.DocumentStatus = 'C' THEN 'ACCEPTED' END as DocumentStatus,
						 CASE  WHEN PoHeaders.Isprint = 1 THEN 'DUPLICATE'  WHEN PoHeaders.Isprint = 0 THEN 'ORIGINAL' END as Isprint,@AdditionalCharge ChargeAmount
						 ,@CreatedUserName CreatedUserName,@ApprovedUserName ApprovedUserName, PoHeaders.PropertyID,Companies.TaxRegistrationNumber1 CompanyTaxNumber 
						 ,Locations.Name locationName, isnull(PoHeaders.SupplierReferenceNo,'') SuppCode, Suppliers.Telephone1 AS supTelno
						 ,Locations.TelNo AS DeliveryTelNo,Locations.SecondEmail AS DeliveyEmail,Locations.ContactPerson AS DeliveryContactPerson
						 ,CASE WHEN PoHeaders.IsApproved=1 THEN @ProcurementName ELSE '-' END AS ProcurementName
						 ,StockItemHeaders.Remarks 'ItemRemark',
						 Suppliers.Remarks 'SupplierRemark'
						 ,PoDetails.Remarks 'PoItemRemarks'
						-- ,CASE WHEN LOCATIONS.ApplyDailyMarketProcess =1 THEN 'SHOW' ELSE '' END AS IsServicePO
						  ,CASE WHEN PoHeaders.potype =2 THEN 'SHOW' ELSE '' END AS IsServicePO
						 ,@ReferenceNo ReferenceNO
						 ,PT.Name PaymentTerm
FROM            PoDetails INNER JOIN
                         PoHeaders ON PoDetails.PoHeaderID = PoHeaders.ID INNER JOIN
                         PoWisePRs ON PoHeaders.ID = PoWisePRs.PoHeaderID AND PoDetails.PoHeaderID = PoWisePRs.PoHeaderID AND PoDetails.StockItemID = PoWisePRs.StockItemID INNER JOIN
                         StockItemHeaders ON PoDetails.StockItemID = StockItemHeaders.Id INNER JOIN
                         Locations ON PoHeaders.LocationID = Locations.Id INNER JOIN
                         Companies ON Locations.CompanyID = Companies.CompanyID INNER JOIN
                         Units ON PoDetails.UnitID = Units.Id INNER JOIN
                         Suppliers ON PoHeaders.SupplierID = Suppliers.ID
						 LEFT JOIN paymentterms PT ON PT.id = PoHeaders.PaymentTermsDetailID
						
where		(PoHeaders.ID = @StockTxnID)
 AND (PoDetails.ApprovedQuantity- PoDetails.ReceivedQuantity) >0
--where		(PoHeaders.ID = 64981)
--select * from PoHeaders where (PoHeaders.ID = 64981)

--updating IsPrint after View
UPDATE PoHeaders
SET Isprint =1
WHERE PoHeaders.ID = @StockTxnID

GO

