--Modified by	: Nivesh
--Modified date	: 2025-07-07
/*
 
 [dbo].[InsertCommiRequest] '{"Id":-1,"Flag":0,"Isprint":false,"PropertyID":1,"LocationID":8,"DepartmentID":1,"TransferLocation":14,"RequestType":"RT","DocumentNo":"1","RequestDate":"2025-05-20T16:38:08.738Z","DocumentStatus":"P","UserProfileID":4168,"JobNo":"1","IsApproved":false,"Remarks":null,"TimeStamp":"2025-05-20T16:38:08.738Z","TransactionTypeCode":"TR","DeliveryDate":"2025-05-20T16:38:08.741Z","RequestedDate":"2025-05-20T00:00:00","UserID":0,"Status":"P","TxnNo":null,"TaxnDate":"0001-01-01T00:00:00","JobID":0,"Urgent":false,"DetailList":[{"StockItemID":2,"UnitID":4,"Remarks":null,"RequestedQuantity":10.0,"RequestedDate":"2025-05-20T00:00:00","DeliveryScheduleID":1,"AdjustedQty":0.0,"ApprovedQuantity":0.0,"Status":null}],"ExpireDatesList":null}'

*/
CREATE PROCEDURE [dbo].[InsertCommiRequest]
   @List VARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
    SET NOCOUNT ON;

	DECLARE @HeaderID INT,@sErrorMessage VARCHAR(500),@LocationID INT,@ProductionLocationID INT,@PropertyID INT,@IsAutoProduction BIT,@RequestedDate DATE
	,@DocumentNo VARCHAR(MAX)


	SELECT @LocationID = LocationID,@RequestedDate =RequestedDate,@PropertyID = PropertyID
    FROM OPENJSON(@List)
    WITH (
		LocationID int,
		RequestedDate DATE,
		PropertyID int
    );


	--Added by Isuru 2025-05-20
	SELECT @IsAutoProduction =ISNULL(IsAutoProduction,0)
	FROM Companies
	WHERE CompanyID = @PropertyID


	IF NOT EXISTS(SELECT 1 FROM OPENJSON(@List, '$.DetailList')
    WITH (
        StockItemID int,
		UnitID int,
		Remarks VARCHAR(500),
		RequestedQuantity MONEY,
		RequestedDate DATE,
		DeliveryScheduleID int,
		AdjustedQty MONEY,
		ApprovedQuantity MONEY

    ) WHERE RequestedQuantity >0)
	BEGIN
		RAISERROR('Zero Quantity',16,1)
		ROLLBACK TRANSACTION
	END


	SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID,'CR')

	IF @DocumentNo IS NULL
	BEGIN
		INSERT INTO TransactionTypeWiseNextNumbers
				( PropertyID ,
					LocationID ,
					TransactionType ,
					NextNumber ,
					LengthOfFormatting
				)
		VALUES  ( @PropertyID , @LocationID ,'CR' ,1 ,6)

		
	END

	SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID,'CR')

	UPDATE  TransactionTypeWiseNextNumbers
    SET     NextNumber = NextNumber + 1
    WHERE   LocationID = @LocationID
    AND TransactionType = 'CR'

	INSERT INTO CommiRequestHeader ( PropertyID, RequestedLocationID,ProductionLocationID,TxnNo,TaxnDate,RequestedDate,UserID,Remarks,
	IsApproved,Status,IsSPOBased, SPOId)
	SELECT PropertyID, TransferLocation,LocationID,@DocumentNo,
	RequestDate,RequestedDate,UserProfileID,Remarks,IsApproved,Status,ISNULL(IsSPOBased,0), DocumentNo
    FROM OPENJSON(@List)
    WITH (
        PropertyID int,
        TransferLocation int,
		LocationID int,
		RequestDate DATE,
		RequestedDate DATE,
		UserProfileID int,
		Remarks VARCHAR(50),
		IsApproved BIT,
		Status VARCHAR(5),
		IsSPOBased BIT,
		DocumentNo INT

    );

	

	SET @HeaderID = SCOPE_IDENTITY()

	INSERT INTO CommiRequestDetails (HeaderID, StockItemID,UnitID,Remarks,RequestedQTY,RequestedDate,DeliveryScheduleID,AdjustedQty,ApprovedQTY,
	Status)
	--SELECT @HeaderID,StockItemID,UnitID,Remarks,RequestedQuantity,CASE WHEN @IsAutoProduction = 0 THEN  @RequestedDate ELSE RequestedDate END,DeliveryScheduleID,AdjustedQty,ApprovedQuantity,'P'
    SELECT @HeaderID,StockItemID,UnitID,Remarks,RequestedQuantity, @RequestedDate,DeliveryScheduleID,AdjustedQty,ApprovedQuantity,'P'
	FROM OPENJSON(@List, '$.DetailList')
    WITH (
        StockItemID int,
		UnitID int,
		Remarks VARCHAR(500),
		RequestedQuantity MONEY,
		RequestedDate DATE,
		DeliveryScheduleID int,
		AdjustedQty MONEY,
		ApprovedQuantity MONEY

    ) WHERE RequestedQuantity >0;

	SELECT @ProductionLocationID = ProductionLocationID 
	FROM CommiRequestHeader
	WHERE ID = @HeaderID

	--sending Tranasctionwise emails 2024-09-27
	EXEC [dbo].[SendTransactionWiseEmailS] 'CR',@HeaderID,@LocationID,@PROPERTYID,'C'
	--END

	



	IF(@IsAutoProduction = 0)
	BEGIN

	UPDATE CommiRequestHeader
	SET Status ='A'
	WHERE ID = @HeaderID

	UPDATE CommiRequestDetails
	SET Status ='A',ApprovedQTY = RequestedQTY,DeliveryScheduleID= 1
	WHERE HeaderID = @HeaderID


	
		EXEC [dbo].[InsertCommiTransfer] @HeaderID

	END

	--End

	SELECT * FROM CommiRequestHeader WHERE Id = @HeaderID
    SET NOCOUNT OFF;
	COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction and raise an error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @sErrorMessage = ERROR_MESSAGE();
        RAISERROR (@sErrorMessage, 16, 1);
    END CATCH;
END;

GO

