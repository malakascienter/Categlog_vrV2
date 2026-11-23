-- =============================================
-- Author:		Nivesh
-- Create date: 2025-05-23
-- Description:	Save Quotaion Request
-- =============================================
--SP_SaveQuotationRequest '<QuotationRequestHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><PurchaseRequestID>7</PurchaseRequestID><PRNo>MST/PR/000006</PRNo><CreatedUserID>4168</CreatedUserID><PropertyID>1</PropertyID><CreatedDate /><DocNo /><filePath>E:\ERP Solutions\Common_NewUI\BackEnd\DestinityERP.Service\UploadCommonExcel\QR\QR_MST_PR_000006_120250527163224.xlsx</filePath><RequestDetailList><QuotationRequestDetail><Id>0</Id><QuotationRequestId>0</QuotationRequestId><SupplierId>159</SupplierId><SupplierName>TCI ENTERPRISES (PVT) LTD</SupplierName></QuotationRequestDetail><QuotationRequestDetail><Id>0</Id><QuotationRequestId>0</QuotationRequestId><SupplierId>162</SupplierId><SupplierName>D EXCLUSIVE HOME DESIGNING</SupplierName></QuotationRequestDetail><QuotationRequestDetail><Id>0</Id><QuotationRequestId>0</QuotationRequestId><SupplierId>160</SupplierId><SupplierName>NEW THARUKSHI GROUP</SupplierName></QuotationRequestDetail></RequestDetailList></QuotationRequestHeader>'

CREATE PROCEDURE [dbo].[SP_SaveQuotationRequest] 
	@XMLDetails nvarchar(max) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN
    BEGIN TRY 
	BEGIN TRANSACTION
	DECLARE @iDocID INT,@PurchaseRequestID INT, @CreatedUserID INT, @PropertyID INT,@QuotationRequestHeaderId INT, @filePath NVARCHAR(max),@NewEmail NVARCHAR(600),@SupID INT, @SupName VARCHAR(600),@EmailBody VARCHAR(MAX), @fileURL NVARCHAR(MAX), @IsOldRequest BIT;

	CREATE TABLE #tempQuotationRequestDetail(
		[Id] [int] ,
		[QuotationRequestId] [int] ,
		[SupplierId] [int] ,
		[SupplierName] [varchar](50) 
	) 

	DECLARE @InsertedIDs_QuotationRequestDetail TABLE (ID INT,SupplierId INT);
	 EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
    -- Insert statements for procedure here
	SELECT @PurchaseRequestID = PurchaseRequestID,
	@CreatedUserID = CreatedUserID,
	@PropertyID = PropertyID,
	@filePath = filePath,
	@fileURL = fileURL,
	@IsOldRequest = IsOldRequest,
	@QuotationRequestHeaderId = Id
	FROM
    OPENXML(@iDocID, '/QuotationRequestHeader', 2)
    WITH (
	PurchaseRequestID INT,
	CreatedUserID INT,
	PropertyID INT,
	filePath nvarchar(max),
	fileURL nvarchar(max),
	IsOldRequest BIT,
	Id INT)

	;WITH RawData AS (
	SELECT 
		SupplierId,
		SupplierName,
		ROW_NUMBER() OVER (PARTITION BY SupplierId ORDER BY SupplierId) AS rn
	FROM OPENXML(@iDocID, '/QuotationRequestHeader/RequestDetailList/QuotationRequestDetail', 2)
	WITH (
		SupplierId INT,
		SupplierName VARCHAR(50)
	)
	)
	INSERT INTO #tempQuotationRequestDetail(SupplierId, SupplierName)
	SELECT SupplierId, SupplierName
	FROM RawData
	WHERE rn = 1;

	IF NOT EXISTS(SELECT 1 FROM #tempQuotationRequestDetail)
	BEGIN
		RAISERROR ( 'Add suplliers', 16, 1 );  
		ROLLBACK TRANSACTION
	END

	IF(@IsOldRequest =0) -- New request
	BEGIN
		IF EXISTS (SELECT 1 FROM [dbo].[QuotationRequestHeader] WHERE PurchaseRequestID = @PurchaseRequestID AND PropertyID = @PropertyID)
		BEGIN
			RAISERROR ( 'PR already exists', 16, 1 );  
			ROLLBACK TRANSACTION		
		END

		--Updation RequestHeader table
		UPDATE RequestHeaders
		SET QuotationStatus ='A'
		WHERE ID = @PurchaseRequestID
		AND PropertyID = @PropertyID
		--End

		--Insert quotaion header---
		INSERT INTO [dbo].[QuotationRequestHeader]
			   ([PurchaseRequestID]
			   ,[CreatedUserID]
			   ,[PropertyID]
			   ,[CreatedDate]
			   ,[DocNo],
			   Status,
			   filePath)
		 VALUES
			   (@PurchaseRequestID
			   ,@CreatedUserID
			   ,@PropertyID
			   ,GETDATE()
			   ,''
			   ,'P'
			   ,@fileURL)
		SET @QuotationRequestHeaderId = SCOPE_IDENTITY()
		---------------------------
		IF EXISTS (SELECT 1 FROM @InsertedIDs_QuotationRequestDetail)
		BEGIN
			DROP TABLE #InsertedIDs_QuotationRequestDetail
		END
		----Insert quotaion detail -----
		INSERT INTO [dbo].[QuotationRequestDetail]
			   ([QuotationRequestId]
			   ,[SupplierId]
			   ,[SupplierName])
			   OUTPUT INSERTED.Id,INSERTED.SupplierId INTO @InsertedIDs_QuotationRequestDetail
		SELECT @QuotationRequestHeaderId QuotationRequestId,
				SupplierId,
				SupplierName
		FROM
		#tempQuotationRequestDetail

		IF EXISTS (SELECT 1 FROM @InsertedIDs_QuotationRequestDetail)
		BEGIN
			INSERT INTO [dbo].[SupplierQuotationUploadDetail]
				   ([QuotationHeaderID]
				   ,[QuotationDetailID]
				   ,[PropertyID]
				   ,[SupplierID]
				   ,[ItemID]
				   ,[Quantity]
				   ,[Price])
			SELECT @QuotationRequestHeaderId QuotationHeaderID
			,qd.Id AS QuotationDetailID
			,@PropertyID AS PropertyID
			,qd.SupplierId AS SupplierID
			,rd.StockItemID ItemID
			,rd.ApprovedQuantity
			,0 
			FROM [dbo].[QuotationRequestHeader] qh
			INNER JOIN [dbo].[QuotationRequestDetail] qd ON qd.QuotationRequestId= qh.Id
			INNER JOIN @InsertedIDs_QuotationRequestDetail IQD ON IQD.ID = qd.Id
			INNER JOIN RequestDetails rd ON rd.RequestHeaderID = qh.PurchaseRequestID
			WHERE qh.PropertyID =@PropertyID AND qh.PurchaseRequestID = @PurchaseRequestID
		END
		--------------------------------
		UPDATE QD
		SET QD.MailStatus = CASE WHEN E.isMailSent = 0 THEN 'F' ELSE 'S' END
		 FROM
		[dbo].[QuotationRequestDetail] QD  
		INNER JOIN [dbo].[QuotationRequestHeader] QH ON QD.QuotationRequestId = QH.Id
		INNER JOIN EmailFailureLog E ON E.PurchaseRequestID = @PurchaseRequestID AND E.SupplierId = QD.SupplierId
		WHERE QH.PurchaseRequestID = @PurchaseRequestID AND QD.MailStatus = 'N' AND qh.PropertyID =@PropertyID 

	END
	ELSE -- Old request
	BEGIN
		IF EXISTS (SELECT 1 FROM [dbo].[QuotationRequestHeader] WHERE PurchaseRequestID = @PurchaseRequestID AND PropertyID = @PropertyID AND Id = @QuotationRequestHeaderId)
		BEGIN
			---------------------------
			IF EXISTS (SELECT 1 FROM @InsertedIDs_QuotationRequestDetail)
			BEGIN
				DROP TABLE #InsertedIDs_QuotationRequestDetail
			END
			----Insert quotaion detail -----
			INSERT INTO [dbo].[QuotationRequestDetail]
				   ([QuotationRequestId]
				   ,[SupplierId]
				   ,[SupplierName])
				   OUTPUT INSERTED.Id,INSERTED.SupplierId INTO @InsertedIDs_QuotationRequestDetail
			SELECT @QuotationRequestHeaderId QuotationRequestId,
					T.SupplierId,
					T.SupplierName
			FROM
			#tempQuotationRequestDetail T
			WHERE T.SupplierId NOT IN (
			 SELECT QD.SupplierId FROM QuotationRequestDetail QD
			 INNER JOIN QuotationRequestHeader QH ON QH.Id = QD.QuotationRequestId
			 WHERE QD.QuotationRequestId = @QuotationRequestHeaderId AND QH.PropertyID = @PropertyID AND QH.PurchaseRequestID = @PurchaseRequestID
			)

			IF EXISTS (SELECT 1 FROM @InsertedIDs_QuotationRequestDetail)
			BEGIN
				INSERT INTO [dbo].[SupplierQuotationUploadDetail]
					   ([QuotationHeaderID]
					   ,[QuotationDetailID]
					   ,[PropertyID]
					   ,[SupplierID]
					   ,[ItemID]
					   ,[Quantity]
					   ,[Price])
				SELECT @QuotationRequestHeaderId QuotationHeaderID
				,qd.Id AS QuotationDetailID
				,@PropertyID AS PropertyID
				,qd.SupplierId AS SupplierID
				,rd.StockItemID ItemID
				,rd.ApprovedQuantity
				,0 
				FROM [dbo].[QuotationRequestHeader] qh
				INNER JOIN [dbo].[QuotationRequestDetail] qd ON qd.QuotationRequestId= qh.Id
				INNER JOIN @InsertedIDs_QuotationRequestDetail IQD ON IQD.ID = qd.Id
				INNER JOIN RequestDetails rd ON rd.RequestHeaderID = qh.PurchaseRequestID
				WHERE qh.PropertyID =@PropertyID AND qh.PurchaseRequestID = @PurchaseRequestID
			END
			--------------------------------
			UPDATE QD
			SET QD.MailStatus = CASE WHEN E.isMailSent = 0 THEN 'F' ELSE 'S' END
				FROM
			[dbo].[QuotationRequestDetail] QD  
			INNER JOIN [dbo].[QuotationRequestHeader] QH ON QD.QuotationRequestId = QH.Id
			INNER JOIN EmailFailureLog E ON E.PurchaseRequestID = @PurchaseRequestID AND E.SupplierId = QD.SupplierId
			WHERE QH.PurchaseRequestID = @PurchaseRequestID AND QD.MailStatus = 'N' AND qh.PropertyID =@PropertyID 
		END
			
		WHILE EXISTS(SELECT 1  FROM #tempQuotationRequestDetail T)
		BEGIN
			SELECT TOP(1) @SupID =SupplierId FROM #tempQuotationRequestDetail T
			
		
	
				UPDATE [dbo].[QuotationRequestDetail]
				SET SendMail = 1
				WHERE SupplierId = @SupID AND QuotationRequestId = @QuotationRequestHeaderId

			DELETE TOP (1) 
			FROM #tempQuotationRequestDetail 
			
		END	


	END

	COMMIT TRANSACTION
 END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRANSACTION
	END 
	
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
    END CATCH;
END
END

GO

