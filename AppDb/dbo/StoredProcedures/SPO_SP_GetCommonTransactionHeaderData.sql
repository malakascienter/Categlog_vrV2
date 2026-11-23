-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-01
-- Modified by		: Nivesh
-- Modified date	: 2025-12-19
-- Description:	Get Common Transaction Header Data
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_GetCommonTransactionHeaderData] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE  @TransactionTypeID INT = 1, 
	@Action CHAR(5) = 'A'
    DECLARE @PropertyId INT        = JSON_VALUE(@JsonDetail, '$.PropertyID');
    DECLARE @UserID INT        = JSON_VALUE(@JsonDetail, '$.UserID');
    DECLARE @TransactionActionID INT = JSON_VALUE(@JsonDetail, '$.TransactionTypeID');
	DECLARE @UserWiseLocationID VARCHAR(5) = JSON_VALUE(@JsonDetail, '$.UserWiseLocationDropDown');
	SELECT @Action =[Action] ,
	@TransactionTypeID = TransactionID
	FROM [dbo].[SPO_CommonTransactionColumnConfiguration]
	WHERE Id = @TransactionActionID

	CREATE TABLE #Temp_Transaction(
		RankNo INT,
		TransactionHeaderID INT,
		UserProfileID INT,
		LocationID VARCHAR(5)
	)
	IF(@Action = 'A')
	BEGIN
		INSERT INTO #Temp_Transaction
		(
			RankNo,
			TransactionHeaderID,
			UserProfileID,
			LocationID
		)
		SELECT 
			RANK() OVER (
				PARTITION BY ta.TransactionTypeID, ta.TransactionHeaderID
				ORDER BY uw.ApproveTypeID
			) AS RankNo,
			TA.TransactionHeaderID,
			TA.UserProfileID,
			UW.LocationId
		FROM [dbo].[SPO_TransactionApprovalLog] TA
		INNER JOIN [dbo].[SPO_UserWiseApproveLevels] UW 
			ON UW.TransactionTypeID = TA.TransactionTypeID 
			AND UW.UserProfileId = TA.UserProfileID
		WHERE TA.TransactionStatus = 'P'
			AND TA.TransactionTypeID = @TransactionTypeID 
			AND TA.IsApproved = 0
			AND TA.LocationID = UW.LocationId
	END
	ELSE IF(@Action = 'CA')
	BEGIN

		IF(@TransactionTypeID =4) --Order Cancelation
		BEGIN
			INSERT INTO #Temp_Transaction
			(
				RankNo,
				TransactionHeaderID,
				UserProfileID,
				LocationID
			)
			SELECT 
				RANK() OVER (
					PARTITION BY TA.TransactionTypeID, TA.TransactionHeaderID
					ORDER BY uw.ApproveTypeID
				) AS RankNo,
				TA.TransactionHeaderID,
				TA.UserProfileID,
				UW.LocationId
			FROM [dbo].[SPO_TransactionApprovalLog] TA
			INNER JOIN SPO_OrderHeader OH ON OH.OrderId = TA.TransactionHeaderID
			INNER JOIN [dbo].[SPO_UserWiseApproveLevels] UW 
				ON UW.TransactionTypeID = TA.TransactionTypeID 
				AND UW.UserProfileId = TA.UserProfileID
			WHERE OH.Status = 'C'
				AND OH.IsApprove= 1
				AND TA.TransactionTypeID =2
				AND TA.LocationID = UW.LocationId
		END
	END

    -- Insert statements for procedure here
	IF (@Action = 'A')
	BEGIN
		IF(@TransactionActionID = 1) -- Customer Approval
		BEGIN
			SELECT C.ID,
			CT.CustomerTypeName,
			C.CustomerName,
			C.MobileNumber,
			C.Email
			FROM [dbo].[SPO_Customer] C
			INNER JOIN [dbo].[SPO_CustomerType] CT ON CT.ID = C.CustomerTypeID
			INNER JOIN #Temp_Transaction T ON T.TransactionHeaderID = C.ID
			WHERE T.UserProfileID = @UserID
			AND T.RankNo =1
		END
		ELSE IF(@TransactionActionID = 2) -- Discount Approval
		BEGIN
			
			SELECT 
			    OH.InvoiceNo AS OrderNo,
				OH.OrderId,
				C.CustomerName,
				 FORMAT(OH.DeliveryDate,'yyyy-MM-dd') AS DeliveryDate,
				CASE 
					WHEN OH.DeliveryTime IS NULL THEN NULL
					ELSE STUFF(RIGHT(CONVERT(VARCHAR(20), OH.DeliveryTime, 100), 7), 6, 0, ' ')
				END AS DeliveryTime,
				LR.description AS DeliveryLocaion,
				ISNULL((
				SELECT SUM(OD.Discount)
				FROM SPO_OrderDetails OD
				WHERE OD.OrderId  = OH.OrderId
				AND   OD.ItemCode = OD.RefItemCode
			    ), 0) AS Discount,
				OH.TotalAmount
			FROM [dbo].[SPO_OrderHeader] OH
			INNER JOIN [dbo].[SPO_Customer] C ON C.ID = OH.CustomerId
			INNER JOIN Location_Ref LR ON LR.code = OH.DeliveryOutlet
			INNER JOIN #Temp_Transaction T ON T.TransactionHeaderID = OH.OrderId
			WHERE T.UserProfileID = @UserID
			AND LR.code = T.LocationID
			AND LR.code = @UserWiseLocationID
			AND OH.OrderCancelStatus IN ('N','X')
			AND OH.Status NOT IN ('X')
			AND T.RankNo =1
		END
		ELSE IF(@TransactionActionID = 4) -- Order Cancelation Approval
		BEGIN
			SELECT 
				InvoiceNo AS OrderNo,
				SOH.OrderId,
				SC.CustomerName,
				SOH.TotalAmount,
				SOH.DocumentChargesPercentage,
				dbo.fn_SPO_GetPaidAmount(SOH.OrderId) AS AdvanceAmount,
				0 AS DocumentCharges,
				SOH.RefundAmount,
				SOH.OrderRemark AS Remark,
				0 AS ExchangeVoucher,
				0 AS VoucherAmount,
				SOH.OrderCancelStatus
			FROM [dbo].[SPO_OrderHeader] SOH
			INNER JOIN SPO_Customer SC ON SC.ID = SOH.CustomerId 
			INNER JOIN #Temp_Transaction T ON T.TransactionHeaderID = SOH.OrderId
			WHERE T.UserProfileID = @UserID
			AND SOH.IsOrderCancel =0
			AND SOH.OrderCancelStatus = 'P'
			AND T.RankNo =1
		END
		ELSE IF(@TransactionActionID = 5) -- Order Approval
		BEGIN
			SELECT 
				SOH.InvoiceNo AS OrderNo,
				SOH.OrderId,
				SC.CustomerName,
				SOH.TotalAmount,
				0 AS DocumentChargesPercentage,
				0 AS AdvanceAmount,
				0 AS DocumentCharges,
				0 AS RefundAmount,
				SOH.OrderRemark AS Remark,
				0 AS ExchangeVoucher,
				0 AS VoucherAmount,
				SOH.Status,
				SOH.DeliveryOutlet,
				CONVERT(VARCHAR(10), SOH.DeliveryDate, 23) AS DeliveryDate
			FROM [dbo].[SPO_OrderHeader] SOH
			INNER JOIN SPO_Customer SC ON SC.ID = SOH.CustomerId 
			INNER JOIN #Temp_Transaction T ON T.TransactionHeaderID = SOH.OrderId
			WHERE T.UserProfileID = @UserID
			AND SOH.IsApprove =0
			AND SOH.Status = 'P'
			AND T.RankNo =1
			AND T.LocationID = CASE WHEN @UserWiseLocationID = '' THEN T.LocationID ELSE @UserWiseLocationID END
		END

	END
	ELSE IF(@Action = 'CA')
	BEGIN
    IF(@TransactionActionID = 3) -- Order Cancelation
    BEGIN
        SELECT 
            SOH.InvoiceNo AS OrderNo,
            SOH.OrderId,
            SC.CustomerName,
            SOH.TotalAmount,
            OT.CancelOrderDocCharge AS DocumentChargesPercentage,
            dbo.fn_SPO_GetPaidAmount(SOH.OrderId) AS AdvanceAmount,
            (dbo.fn_SPO_GetPaidAmount(SOH.OrderId) * OT.CancelOrderDocCharge / 100) AS DocumentCharges,
            (dbo.fn_SPO_GetPaidAmount(SOH.OrderId) - (dbo.fn_SPO_GetPaidAmount(SOH.OrderId) * OT.CancelOrderDocCharge / 100)) AS RefundAmount,
            SOH.OrderRemark AS Remark,
            0 AS ExchangeVoucher,
            0 AS VoucherAmount,
            SOH.OrderCancelStatus
        FROM [dbo].[SPO_OrderHeader] SOH
        INNER JOIN SPO_Customer SC ON SC.ID = SOH.CustomerId 
        INNER JOIN #Temp_Transaction T ON T.TransactionHeaderID = SOH.OrderId
        INNER JOIN SPO_OrderType AS OT ON OT.ID = SOH.OrderTypeId
        WHERE T.UserProfileID = @UserID
        AND SOH.IsOrderCancel = 0
        AND SOH.OrderCancelStatus IN ('N','X')
        AND T.RankNo = 1
    END
  END
END

GO

