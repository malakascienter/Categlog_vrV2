CREATE PROCEDURE [dbo].[SP_Approvals_SupplierPrice]
    @XMLDetails XML,
    @status INT OUTPUT,
    @message VARCHAR(20) OUTPUT,
    @executesql NVARCHAR(MAX) OUTPUT
AS
DECLARE @iDocID INT;

DECLARE @RequestTransactionTypeID INT, --for MRN TransactionID 16
        @ApprovedDate DATETIME,
        @UserProfileID BIGINT,
        @RequestHeaderID BIGINT,
        @ApprovalLevelID INT,
        @StockItemID BIGINT,
        @ApprovedQuantity MONEY,
        @RequestDetailID BIGINT,
        @DepartmentID INT,
        @IsReject BIT;

DECLARE @PropertyID INT,
        @LocationID INT,
        @TransactionID INT,
        @TransactionHeaderID BIGINT,
        @statusIN [INT];




SET @statusIN = 0;
SET @message = '';

DECLARE @reqestedQTY INT,
        @Balance INT,
        @BoqID INT,
        @ProjectID INT;

EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

SELECT @RequestTransactionTypeID = RequestTransactionTypeID,
       @ApprovedDate = ApprovedDate,
       @UserProfileID = UserProfileID,
       @RequestHeaderID = RequestHeaderID,
       @ApprovalLevelID = ApprovalLevelID,
	   @IsReject = IsReject
FROM
    OPENXML(@iDocID, '/Approved', 2)
    WITH
    (
        RequestTransactionTypeID INT,
        IsReject BIT,
        ApprovedDate DATETIME,
        UserProfileID BIGINT,
        RequestHeaderID BIGINT,
        ApprovalLevelID INT
    );

IF @IsReject = 0
BEGIN
    UPDATE dbo.ApprovalLogs
    SET IsComplete = 1,
        DocStatus = 'C',
        ApprovalDate = GETDATE()
    WHERE TransactionID = @RequestTransactionTypeID
          AND TransactionHeaderID = @RequestHeaderID
          AND ApprovalLevelID = @ApprovalLevelID;
    SELECT @PropertyID = PropertyID,
           @LocationID = LocationID,
           @TransactionID = TransactionID,
           @TransactionHeaderID = TransactionHeaderID
    FROM dbo.ApprovalLogs
    WHERE TransactionID = @RequestTransactionTypeID
          AND TransactionHeaderID = @RequestHeaderID
          AND ApprovalLevelID = @ApprovalLevelID;

    EXEC [SP_Chek_Approvels_For_BOQ] @PropertyID,
                                     @LocationID,
                                     @TransactionID,
                                     @TransactionHeaderID;
END;
ELSE
BEGIN
    UPDATE dbo.ApprovalLogs
    SET IsComplete = 1,
        DocStatus = 'X',
        ApprovalDate = GETDATE()
    WHERE TransactionID = @RequestTransactionTypeID
          AND TransactionHeaderID = @RequestHeaderID
          AND ApprovalLevelID = @ApprovalLevelID;
    SELECT @PropertyID = PropertyID,
           @LocationID = LocationID,
           @TransactionID = TransactionID,
           @TransactionHeaderID = TransactionHeaderID
    FROM dbo.ApprovalLogs
    WHERE TransactionID = @RequestTransactionTypeID
          AND TransactionHeaderID = @RequestHeaderID
          AND ApprovalLevelID = @ApprovalLevelID;

    EXEC [SP_Chek_Approvels_For_BOQ] @PropertyID,
                                     @LocationID,
                                     @TransactionID,
                                     @TransactionHeaderID;
END;

GO

