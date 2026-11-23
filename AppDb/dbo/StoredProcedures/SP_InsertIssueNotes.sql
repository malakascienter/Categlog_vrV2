
-- exec [dbo].[SP_InsertIssueNotes] '<StockTransactions><StockTransaction><StockItemID>3419</StockItemID><Quantity>0.01</Quantity></StockTransaction><StockTransaction><StockItemID>1996</StockItemID><Quantity>0.5</Quantity></StockTransaction></StockTransactions>',1,4168

-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-10-08
-- Modified by:	Nivesh
-- Modified Date: 2024-10-09
-- Description:	SP to INSERT iSSUE NOTES USING hOUSE keep API
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertIssueNotes]
(
    @XMLDetails XML,
	@PropertyID INT,
	@UserID INT =NULL
)
AS
DECLARE @statusIN [INT];
SET @statusIN = 1;

SET NOCOUNT ON;
DECLARE @trancount INT;
SET @trancount = @@trancount;

--Added by Isuru 2023-9-20
DECLARE @tempIssueNoteId INT, @headerID INT

insert into tempIssueNote (XmlDATA)
select convert(varchar(max),  @XMLDetails) 

select top(1)@tempIssueNoteId= ID 
from tempIssueNote
order by ID desc

BEGIN
    BEGIN TRY 
	BEGIN TRANSACTION

	DECLARE @UserData TABLE(
	Id INT,
	UserName NVARCHAR(200),
	EmployeeId INT
	)
	DECLARE @iDocID INT,@XMLHeaderPU XML, @HousekeepingAPILocationID int =NULL,
	@HousekeepingAPIDepartmentID int =NULL,
	@HousekeepingAPIUserID int =NULL,@IsCentralLogin BIT; 

	IF(@PropertyID IS NULL)
	BEGIN
		RAISERROR ( 'Provide Property', 16, 1 );  
		ROLLBACK TRANSACTION
	END

	IF(@UserID IS NULL)
	BEGIN
		RAISERROR ( 'Provide User', 16, 1 );  
		ROLLBACK TRANSACTION
	END

	SELECT @HousekeepingAPILocationID = HousekeepingAPILocationID,@HousekeepingAPIDepartmentID = HousekeepingAPIDepartmentID ,@HousekeepingAPIUserID = HousekeepingAPIUserID
	FROM Companies WHERE CompanyID = @PropertyID
   
   SET @HousekeepingAPIUserID = @UserID;
   IF(@HousekeepingAPILocationID IS NULL)
	BEGIN
		RAISERROR ( 'Provide Location', 16, 1 );  
		ROLLBACK TRANSACTION
	END
	IF(@HousekeepingAPIDepartmentID IS NULL)
	BEGIN
		RAISERROR ( 'Provide Department', 16, 1 );  
		ROLLBACK TRANSACTION
	END
	IF(@HousekeepingAPIUserID IS NULL)
	BEGIN
		RAISERROR ( 'Provide UserID', 16, 1 );  
		ROLLBACK TRANSACTION
	END

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @PropertyID 
	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserData
		SELECT Id, UserName, EmpNumber
		FROM [dbo].[CentralUsers]
		WHERE IsActive=1
	END
	ELSE
	BEGIN
		INSERT INTO @UserData
		SELECT Id, UserName,EmployeeId
		FROM UserMasters
	END

	IF NOT EXISTS(SELECT 1 FROM @UserData WHERE Id = @HousekeepingAPIUserID)
	BEGIN
		RAISERROR ( 'User Not exsists', 16, 1 );  
		ROLLBACK TRANSACTION	
	END

	IF NOT EXISTS(SELECT 1 FROM Locations WHERE Id = @HousekeepingAPILocationID)
	BEGIN
		RAISERROR ( 'Location Not exsists', 16, 1 );  
		ROLLBACK TRANSACTION	
	END

	IF NOT EXISTS(SELECT 1 FROM Departments WHERE Id = @HousekeepingAPIDepartmentID)
	BEGIN
		RAISERROR ( 'Departments Not exsists', 16, 1 );  
		ROLLBACK TRANSACTION	
	END

   EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	CREATE TABLE #TempStockItemDetail(
		StockItemID INT,
		Quantity DECIMAL(18,8)
	)

	INSERT INTO #TempStockItemDetail
	SELECT *
	FROM
    OPENXML(@iDocID, 'StockTransactions/StockTransaction', 2)
    WITH(
	StockItemID INT,
	Quantity DECIMAL(18,8)	
	)

	SET @XMLHeaderPU = 
	(SELECT
		'192.168.1.203' AS IPAddress,
		@HousekeepingAPIUserID AS CreatedUserID,
		@HousekeepingAPIUserID AS LastModUserID,
		GETDATE() AS CreatedDate,
		GETDATE() AS LastModDate,
		0 AS Id,
		'false' AS IsPrint,
		'false' AS IsApproved,
		'IN' AS TransactionType,
		GETDATE() AS TransactionDate,
		@PropertyID AS PropertyID,
		@HousekeepingAPILocationID AS LocationID,
		'' AS ReferenceNo,
		0 AS SupplierID,
		-999 AS ReferenceID,
		@HousekeepingAPIDepartmentID AS DepartmentID,
		@HousekeepingAPIUserID AS UserProfileID,
		0 AS TransferLocationID,
		3 AS TransactionID,
		'M' AS Mode,
		0 AS SuppCurrencyID,
		1 AS ExchangeRate,
		NULL AS InvoiceDate,
		'false' AS IsTrasferIn,
		'true' AS IsDirectIssue,
		0 AS GRNTypeID,

		-- Subquery for StockTransactionDetail list as nested XML
		(
			SELECT
				null AS IPAddress,
				@HousekeepingAPIUserID AS CreatedUserID,
				@HousekeepingAPIUserID AS LastModUserID,
				GETDATE() AS CreatedDate,
				GETDATE() AS LastModDate,
				0 AS Id,
				1 AS StockTransactionHeaderID,
				TD.StockItemID,
				TD.Quantity,
				SD.AveragePrice AS UnitPrice,
				SD.MasterUnitID AS TxnUnitID,
				0 AS MasterUnitID,
				0 AS MasterUnitConversion,
				0 AS ReportUnitID,
				0 AS ReportUnitConversion,
				0 AS DiscountValue,
				0 AS DiscountPercentage,
				0 AS TimeStamp,
				0 AS StockMasterQuantity,
				0 AS StockMasterAveragePrice,
				TD.Quantity AS NewQuantity,
				0 AS NewAveragePrice,
				@HousekeepingAPIUserID AS UserProfileId,
				0 AS CostTransactionAccountID,
				0 AS PurchaseTransactionAccountID,
				'M' AS TxnType,
				SD.QuantityInHand AS BalanceQuantity,
				0 AS ReturnQuantity,
				0 AS ItemUnitPriceInSuppCurrency,
				0 AS TBPHeaderId,
				-1 AS CurrencyId
				,null AS BrandedItem
			FROM #TempStockItemDetail TD
			INNER JOIN StockItemDetails SD ON SD.StockItemId = TD.StockItemID AND SD.LocationID = @HousekeepingAPILocationID AND SD.PropertyID = @PropertyID
			FOR XML PATH('StockTransactionDetail'), TYPE
		) AS StockDetailList

	FOR XML PATH('StockTransactionHeader'), 
		 ELEMENTS XSINIL, TYPE);

-- Output the XML
	--set @XMLHeaderPU ='<StockTransactionHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>192.168.1.203</IPAddress><CreatedUserID>4168</CreatedUserID><LastModUserID>4168</LastModUserID><CreatedDate>2024-10-09T08:49:34.296Z</CreatedDate><LastModDate>2024-10-09T08:49:34.296Z</LastModDate><Id>0</Id><IsPrint>false</IsPrint><IsApproved>false</IsApproved><TransactionType>IN</TransactionType><TransactionDate>2024-10-09T08:49:34.296Z</TransactionDate><PropertyID>1</PropertyID><LocationID>12</LocationID><ReferenceNo /><SupplierID>0</SupplierID><ReferenceID>-999</ReferenceID><DepartmentID>25</DepartmentID><UserProfileID>4168</UserProfileID><TransferLocationID>0</TransferLocationID><TransactionID>3</TransactionID><Mode>M</Mode><SuppCurrencyID>0</SuppCurrencyID><ExchangeRate>1</ExchangeRate><InvoiceDate xsi:nil="true" /><IsTrasferIn>false</IsTrasferIn><IsDirectIssue>true</IsDirectIssue><GRNTypeID>0</GRNTypeID><StockDetailList><StockTransactionDetail><IPAddress /><CreatedUserID>4168</CreatedUserID><LastModUserID>4168</LastModUserID><CreatedDate>2024-10-09T08:49:34.296Z</CreatedDate><LastModDate>2024-10-09T08:49:34.296Z</LastModDate><Id>0</Id><StockTransactionHeaderID>1</StockTransactionHeaderID><StockItemID>3419</StockItemID><Quantity>0.1</Quantity><UnitPrice>50</UnitPrice><TxnUnitID>1</TxnUnitID><MasterUnitID>0</MasterUnitID><MasterUnitConversion>0</MasterUnitConversion><ReportUnitID>0</ReportUnitID><ReportUnitConversion>0</ReportUnitConversion><DiscountValue>0</DiscountValue><DiscountPercentage>0</DiscountPercentage><TimeStamp>0</TimeStamp><StockMasterQuantity>0</StockMasterQuantity><StockMasterAveragePrice>0</StockMasterAveragePrice><NewQuantity>0.1</NewQuantity><NewAveragePrice>0</NewAveragePrice><UserProfileId>4168</UserProfileId><CostTransactionAccountID>0</CostTransactionAccountID><PurchaseTransactionAccountID>0</PurchaseTransactionAccountID><TxnType>M</TxnType><BalanceQuantity>0.89</BalanceQuantity><ReturnQuantity>0</ReturnQuantity><ItemUnitPriceInSuppCurrency>0</ItemUnitPriceInSuppCurrency><TBPHeaderId>0</TBPHeaderId><CurrencyId>-1</CurrencyId><BrandedItem xsi:nil="true" /></StockTransactionDetail><StockTransactionDetail><IPAddress /><CreatedUserID>4168</CreatedUserID><LastModUserID>4168</LastModUserID><CreatedDate>2024-10-09T08:49:34.296Z</CreatedDate><LastModDate>2024-10-09T08:49:34.296Z</LastModDate><Id>0</Id><StockTransactionHeaderID>1</StockTransactionHeaderID><StockItemID>1996</StockItemID><Quantity>10</Quantity><UnitPrice>1081.537781</UnitPrice><TxnUnitID>11</TxnUnitID><MasterUnitID>0</MasterUnitID><MasterUnitConversion>0</MasterUnitConversion><ReportUnitID>0</ReportUnitID><ReportUnitConversion>0</ReportUnitConversion><DiscountValue>0</DiscountValue><DiscountPercentage>0</DiscountPercentage><TimeStamp>0</TimeStamp><StockMasterQuantity>0</StockMasterQuantity><StockMasterAveragePrice>0</StockMasterAveragePrice><NewQuantity>10</NewQuantity><NewAveragePrice>0</NewAveragePrice><UserProfileId>4168</UserProfileId><CostTransactionAccountID>0</CostTransactionAccountID><PurchaseTransactionAccountID>0</PurchaseTransactionAccountID><TxnType>M</TxnType><BalanceQuantity>69.36</BalanceQuantity><ReturnQuantity>0</ReturnQuantity><ItemUnitPriceInSuppCurrency>0</ItemUnitPriceInSuppCurrency><TBPHeaderId>0</TBPHeaderId><CurrencyId>-1</CurrencyId><BrandedItem xsi:nil="true" /></StockTransactionDetail></StockDetailList></StockTransactionHeader>';
	EXEC SP_InsertStockTransactions @XMLHeaderPU,'',0,'',@headerID OUTPUT,0
	
	IF @headerID IS NOT NULL
	BEGIN
		UPDATE tempIssueNote
		SET StockTransactionHeaderID = @headerID
		WHERE ID = @tempIssueNoteId
	END
	DROP TABLE #TempStockItemDetail
	 
	COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
	
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	INSERT INTO [dbo].[InsertIssueNotes_ERR_LOG](HeaderID,DocumentNo,ErrorProcedure, Response, SysDate)
	VALUES(0,'', @ErrorProcedure,@ErrorMessage,GETDATE())


    END CATCH;
	
END;

GO

