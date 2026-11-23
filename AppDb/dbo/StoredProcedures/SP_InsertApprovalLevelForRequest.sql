--=============================================
-- Last Modified by     : Nivesh
-- Last Modified date   : 2025-11-18
--=============================================
CREATE PROCEDURE [dbo].[SP_InsertApprovalLevelForRequest]
    (
      @PropertyID INT ,
      @LocationID INT ,
      @TransactionID INT ,
      @TransactionHeaderID INT
   
    )
AS 
insert into AAdata (propertyID,locationID,transactionID,TH)
SELECT @PropertyID propertyID, @LocationID locationID, @TransactionID transactionID,@TransactionHeaderID TH 
--select * from AAdata
--drop table AAdata

declare @departmentID int 

DECLARE @InsertedIDs_ApprovalLogs TABLE (ID INT);
DECLARE @ApprovalLogID INT;

IF @TransactionID = 8 -- Transfer request apprival set to request locations 
BEGIN

	SELECT @LocationID = TransferLocation FROM RequestHeaders WHERE ID= @TransactionHeaderID
	select @LocationID 
END
else
IF @TransactionID = 11 OR @TransactionID = 1 -- Transfer request apprival set to request locations 
BEGIN

	SELECT @departmentID = DepartmentID FROM RequestHeaders WHERE ID= @TransactionHeaderID
	select @departmentID  dept
END


--- Added by Isuru 2023-09-21 for Inserting correct UserID
DECLARE @UserProfileID INT
IF(@TransactionID=1 OR @TransactionID=11 OR @TransactionID=8 OR @TransactionID=14)
BEGIN
SELECT @UserProfileID = UserProfileID
FROM RequestHeaders
WHERE Id = @TransactionHeaderID
END

IF(@TransactionID = 2)
BEGIN

SELECT @UserProfileID = UserProfileID
FROM PoHeaders
WHERE Id =@TransactionHeaderID

END

IF(@TransactionID = 7)
BEGIN
--SELECT @UserProfileID = UserProfileID
--FROM StockTransactionHeaders
--WHERE Id= @TransactionHeaderID

SELECT @UserProfileID = CreatedUserId
FROM GRNApprovalLog
WHERE Id= @TransactionHeaderID

END


IF (@TransactionID = 81)
BEGIN
SELECT @UserProfileID = CreatedUserId 
FROM TourGuideCompanies
WHERE ID = @TransactionHeaderID

END

IF (@TransactionID = 82)
BEGIN
SELECT @UserProfileID = CreatedUserId 
FROM TourGuideMaster
WHERE ID = @TransactionHeaderID

END

--added by isuru 2026-10-28: Supplier Grading (SGR) - requesting user (ApprovalLogs.CreatedUserID is NOT NULL)
IF (@TransactionID = (SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'))
BEGIN
SELECT @UserProfileID = CreatedUserId
FROM SupplierEvaluationHeader
WHERE ID = @TransactionHeaderID
END

--End

select @departmentID '@departmentID'
    DECLARE @MinValue INT
    SET @MinValue = 0

    INSERT  INTO dbo.ApprovalLogs
            ( SeqID ,
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
				OUTPUT INSERTED.Id INTO @InsertedIDs_ApprovalLogs --Added by Isuru 2025-05-14
			  SELECT  SeqID ,
                    @TransactionID ,
                    ApprovalTypeID ,
                    @TransactionHeaderID ,
                   @PropertyID ,
                    CASE WHEN @TransactionID=11 OR @TransactionID=1 then @departmentID else   @LocationID end ,
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
                    AND T.LocationID =  CASE WHEN @TransactionID=11 OR @TransactionID=1 then @departmentID ELSE  @LocationID END 
                    AND T.TransactionID = @TransactionID
                    AND MinValue = 0

								  SELECT  SeqID ,
                    @TransactionID ,
                    ApprovalTypeID ,
                    @TransactionHeaderID ,
                    @PropertyID ,
                    @LocationID ,
                    0 ,
                    'P' ,
                    T.IPAddress,
                    T.CreatedUserID,
                    T.LastModUserID,
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
                    AND T.LocationID =  CASE WHEN @TransactionID=11 OR @TransactionID=1 then @departmentID ELSE  @LocationID END 
                    AND T.TransactionID = @TransactionID
                    AND MinValue = 0



			while exists (select 1 from @InsertedIDs_ApprovalLogs)
			begin
				select top(1) @ApprovalLogID = ID from @InsertedIDs_ApprovalLogs

				SELECT @ApprovalLogID ApprovalLogID

				EXEC Inventry_AuditTail_WriteToLog 'ApprovalLogs', @ApprovalLogID, 'INV', 'APL', 'I', @UserProfileID,@PropertyID, '', ''

				delete top(1) from @InsertedIDs_ApprovalLogs
			end



    IF @TransactionID = 2
        BEGIN

            SET @MinValue = ( SELECT    NetTotal
                              FROM      dbo.PoHeaders
                              WHERE     PropertyID = @PropertyID
                                        AND LocationID = @LocationID
                                        AND Id = @TransactionHeaderID
                            )
							

        END

    IF @TransactionID = 1
        OR @TransactionID = 11
        OR @TransactionID = 14
        OR @TransactionID = 33
        BEGIN
            SET @MinValue = ( SELECT    SUM(sd.AveragePrice
                                            * rd.RequestedQuantity)
                              FROM      dbo.StockItemDetails sd
                                        INNER JOIN dbo.RequestDetails rd ON sd.StockItemHeaderID = rd.StockItemID
                              WHERE     rd.RequestHeaderID = @TransactionHeaderID
                                        AND sd.LocationID = @LocationID
                                        AND sd.PropertyID = @PropertyID
                            )
							
        END

    INSERT  INTO dbo.ApprovalLogs
            ( SeqID ,
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
			OUTPUT INSERTED.Id INTO @InsertedIDs_ApprovalLogs --Added by Isuru 2025-05-14
            SELECT  SeqID ,
                    @TransactionID ,
                    ApprovalTypeID ,
                    @TransactionHeaderID ,
                    @PropertyID ,
                    CASE WHEN @TransactionID=11 OR @TransactionID=1 then @departmentID else   @LocationID end ,
                    0 ,
                    'P' ,
                    t.IPAddress ,
                    @UserProfileID,
                   @UserProfileID,
                    GETDATE() ,
                    GETDATE() ,
					U.UserProfileId
            FROM    dbo.TransactionWiseApprovalTypes t
			INNER JOIN UserWiseApproveLevels U ON 
				t.TransactionID = U.TransactionTypeID AND 
				T.LocationID = U.LocationId AND 
				T.PropertyID = U.PropertyId AND 
				T.ApprovalTypeID = U.ApproveLevelID 

            WHERE  t. PropertyID = @PropertyID
                    AND t.LocationID = CASE WHEN @TransactionID=11 OR @TransactionID=1 then @departmentID ELSE  @LocationID END 
                    AND TransactionID = @TransactionID
                    AND MinValue <= @MinValue
                    AND MinValue <> 0
                    AND MinValue IS NOT NULL

			while exists (select 1 from @InsertedIDs_ApprovalLogs)
			begin
				select top(1) @ApprovalLogID = ID from @InsertedIDs_ApprovalLogs

				SELECT @ApprovalLogID ApprovalLogID

				EXEC Inventry_AuditTail_WriteToLog 'ApprovalLogs', @ApprovalLogID, 'INV', 'APL', 'I', @UserProfileID,@PropertyID, '', ''

				delete top(1) from @InsertedIDs_ApprovalLogs
			end
			
            

 select  @PropertyID, @LocationID,
        @TransactionID, @TransactionHeaderID

    EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID, @LocationID,
        @TransactionID, @TransactionHeaderID

		--select @PropertyID,@LocationID,
  --      @TransactionID, @TransactionHeaderID '555555555'

GO

