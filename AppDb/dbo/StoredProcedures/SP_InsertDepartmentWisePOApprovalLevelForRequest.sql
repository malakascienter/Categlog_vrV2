-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-17
-- Description:	Approval levels for department-wise PO
-- =============================================
create   PROCEDURE [dbo].[SP_InsertDepartmentWisePOApprovalLevelForRequest] 
(
	@PropertyID INT ,
	@LocationID INT ,
	@TransactionID INT ,
	@TransactionHeaderID INT,
	@DepartmentID INT = -999
)
AS
BEGIN
    
    DECLARE @RequestBody NVARCHAR(MAX),
    @UserProfileID INT,
    @MinValue INT =0,
    @ApprovalLogID INT,
    @CUNT INT,
    @RejectedCount INT
	
    INSERT INTO AAdata (
    propertyID,
    locationID,
    transactionID,
    TH,
    RequestBody
    )
	SELECT @PropertyID propertyID,
	@LocationID locationID,
	@TransactionID transactionID,
	@TransactionHeaderID TH ,
	@RequestBody RequestBody
    
    SET NOCOUNT ON;
	

	DECLARE @InsertedIDs_ApprovalLogs TABLE (
    ID INT
    );
	
	SET @RequestBody = (
	SELECT @PropertyID propertyID,
	@LocationID locationID,
	@TransactionID transactionID,
	@TransactionHeaderID TH ,
	@DepartmentID DepartmentID
	FOR JSON PATH)



	SELECT @UserProfileID = UserProfileID
	FROM PoHeaders
	WHERE Id =@TransactionHeaderID

    SET @MinValue = ( SELECT    ISNULL(NetTotal,0)
                        FROM      dbo.PoHeaders
                        WHERE     PropertyID = @PropertyID
                                AND LocationID = @LocationID
                                AND Id = @TransactionHeaderID
                    )

    INSERT  INTO dbo.ApprovalLogs
    (   SeqID ,
        TransactionID ,
        ApprovalLevelID ,
        TransactionHeaderID ,
        PropertyID ,
        LocationID ,
        IsComplete ,
        DocStatus ,
        IPAddress ,
        CreatedUserID ,
        LastModUserID ,
        CreatedDate ,
        LastModDate ,
        ApprovalUserID
    )
	OUTPUT INSERTED.Id INTO @InsertedIDs_ApprovalLogs 
	SELECT  SeqID ,
        @TransactionID ,
        ApprovalTypeID ,
        @TransactionHeaderID ,
        @PropertyID ,
        @DepartmentID ,
        0 ,
        'P' ,
        T.IPAddress,
        @UserProfileID,
        @UserProfileID,
        GETDATE() ,
        GETDATE() ,
        U.UserProfileId
    FROM    dbo.TransactionWiseApprovalTypes T
	INNER JOIN UserWiseApproveLevels U ON 
		T.TransactionID = U.TransactionTypeID AND 
		T.LocationID = U.LocationId AND 
		T.PropertyID = U.PropertyId AND 
		T.ApprovalTypeID = U.ApproveLevelID
    WHERE   T.PropertyID = @PropertyID 
            AND T.LocationID =  @DepartmentID 
            AND T.TransactionID = @TransactionID
            AND (MinValue = 0 OR ( MinValue <= @MinValue
            AND MinValue <> 0
            AND MinValue IS NOT NULL))

	WHILE EXISTS (
        SELECT 1 
        FROM 
        @InsertedIDs_ApprovalLogs
    )
	BEGIN
		SELECT TOP(1) 
            @ApprovalLogID = ID 
        FROM @InsertedIDs_ApprovalLogs

		SELECT @ApprovalLogID ApprovalLogID

		EXEC Inventry_AuditTail_WriteToLog 'ApprovalLogs', @ApprovalLogID, 'INV', 'APL', 'I', @UserProfileID,@PropertyID, '', ''

		DELETE TOP(1) 
        FROM @InsertedIDs_ApprovalLogs
	END

    SET @CUNT = (SELECT COUNT(*) 
			 FROM dbo.ApprovalLogs 
			 WHERE PropertyID= @PropertyID 
			  AND LocationID=@DepartmentID
			 AND TransactionHeaderID= @TransactionHeaderID 
             AND TransactionID = @TransactionID 
			 AND DocStatus <> 'C')
    
    SET @RejectedCount = (  SELECT COUNT(*) 
        FROM ApprovalLogs
	    WHERE PropertyID=@PropertyID 
        AND LocationID=@DepartmentID 
	    AND TransactionHeaderID= @TransactionHeaderID 
        AND TransactionID = @TransactionID 
	    AND DocStatus ='X')

    IF(@CUNT =0)
    BEGIN
        UPDATE  dbo.PoHeaders
		SET   isApproved     = 1 
			, DocumentStatus ='P'
		WHERE Id = @TransactionHeaderID 
    END
    ELSE IF (@RejectedCount>0)
    BEGIN
        Update  dbo.POHeaders
		SET isApproved=0 ,
        DocumentStatus ='X'
		WHERE POHeaderID = @TransactionHeaderID 
    END
END

GO

