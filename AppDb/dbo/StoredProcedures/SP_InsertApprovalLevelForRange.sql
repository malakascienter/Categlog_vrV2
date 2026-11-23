-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-06-22
-- Description:	give permission for range wise approval levels 

-- SP_InsertApprovalLevelForRange  1,0,1,7347,58,4168

-- =============================================
CREATE   PROCEDURE [dbo].[SP_InsertApprovalLevelForRange] 
	@PropertyID INT ,
    @LocationID INT=0 ,
    @TransactionID INT ,
    @TransactionHeaderID INT, 
	@DepartmentID INT =0,
	@UserProfileID INT,
    @TotalAmount DECIMAL(18,6) =0
	
AS
BEGIN
	SET NOCOUNT ON;

	

    DECLARE @InsertedIDs_ApprovalLogs TABLE (ID INT) ;
    DECLARE @ApprovalLogID INT;

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
                    AND U.RangeFrom = 0 AND U.RangeTo = 0

								 



			while exists (select 1 from @InsertedIDs_ApprovalLogs)
			begin
				select top(1) @ApprovalLogID = ID from @InsertedIDs_ApprovalLogs

				SELECT @ApprovalLogID ApprovalLogID

				EXEC Inventry_AuditTail_WriteToLog 'ApprovalLogs', @ApprovalLogID, 'INV', 'APL', 'I', @UserProfileID,@PropertyID, '', ''

				delete top(1) from @InsertedIDs_ApprovalLogs
			end



    IF @TransactionID = 2
        BEGIN

            SET @TotalAmount = ( SELECT    NetTotal
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
        OR @TransactionID = 8
        BEGIN
            SET @TotalAmount = ( SELECT    SUM(sd.AveragePrice
                                            * rd.RequestedQuantity)
                              FROM      dbo.StockItemDetails sd
                                        INNER JOIN dbo.RequestDetails rd ON sd.StockItemHeaderID = rd.StockItemID
                              WHERE     rd.RequestHeaderID = @TransactionHeaderID
                                        AND sd.LocationID = @LocationID
                                        AND sd.PropertyID = @PropertyID
                            )
							
        END

        
        select @TotalAmount TotalAmount 

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
                    AND U.RangeFrom IS NOT NULL 
                    AND U.RangeFrom <> 0
                    AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))
                   

			while exists (select 1 from @InsertedIDs_ApprovalLogs)
			begin
				select top(1) @ApprovalLogID = ID from @InsertedIDs_ApprovalLogs

				SELECT @ApprovalLogID ApprovalLogID

				EXEC Inventry_AuditTail_WriteToLog 'ApprovalLogs', @ApprovalLogID, 'INV', 'APL', 'I', @UserProfileID,@PropertyID, '', ''

				delete top(1) from @InsertedIDs_ApprovalLogs
			end

            EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID, @LocationID,@TransactionID, @TransactionHeaderID


			 
END

GO

