-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-01
-- Modified by		: Nivesh
-- Modified date	: 2025-12-19
-- Description:	Get Common Transaction Detail Data
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_GetCommonTransactionDetailData] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PropertyId INT        = JSON_VALUE(@JsonDetail, '$.PropertyID');
    DECLARE @UserID INT        = JSON_VALUE(@JsonDetail, '$.UserID');
    DECLARE @TransactionTypeID INT = JSON_VALUE(@JsonDetail, '$.TransactionTypeID');
	DECLARE @rawData NVARCHAR(MAX);
    DECLARE @Id INT; 
	SET @rawData = JSON_QUERY(@JsonDetail, '$.rawData');

    -- Insert statements for procedure here
	IF(@TransactionTypeID =1) -- Customer Approval
	BEGIN
		SET @Id = JSON_VALUE(@rawData, '$.ID');

		SELECT 
			C.ID,
			C.FullName,
			FORMAT(C.DateOfBirth, 'yyyy-MM-dd') AS DateOfBirth,
			C.[Address],
			C.CreditLimit,
			C.CreditPeriod,
			C.EmployeeCode,
			C.isActive,
			C.IsEbillRequest
		FROM
		[dbo].[SPO_Customer] C
		WHERE C.ID = @Id
	END
	ELSE IF(@TransactionTypeID =2) -- Discount Approval
	BEGIN
		SET @Id = JSON_VALUE(@rawData, '$.OrderId');

		SELECT 
			OD.OrderDetailId,
			OD.OrderId,
			OD.ItemCode,
			OD.ItemName,
			OD.Price,
			OD.Qty,
			OD.Discount,
			OD.DiscountType,
			OD.IsDiscount
		FROM
		[dbo].[SPO_OrderDetails] OD
		WHERE OD.OrderId = @Id AND OD.IsDiscount = 1 AND OD.IsDiscountApprove = 0
	END
	ELSE IF(@TransactionTypeID =3) -- Order Cancelation
	BEGIN
		SET @Id = JSON_VALUE(@rawData, '$.OrderId');

		SELECT 
			OD.OrderDetailId,
			OD.OrderId,
			OD.ItemCode,
			OD.ItemName,
			OD.Price,
			OD.Qty,
			OD.Discount,
			OD.DiscountType,
			OD.IsDiscount
		FROM
		[dbo].[SPO_OrderDetails] OD
		WHERE OD.OrderId = @Id
	END
	ELSE IF(@TransactionTypeID =4) -- Order Cancelation Approval
	BEGIN
		SET @Id = JSON_VALUE(@rawData, '$.OrderId');

		SELECT 
			OD.OrderDetailId,
			OD.OrderId,
			OD.ItemCode,
			OD.ItemName,
			OD.Price,
			OD.Qty,
			OD.Discount,
			OD.DiscountType,
			OD.IsDiscount
		FROM
		[dbo].[SPO_OrderDetails] OD
		WHERE OD.OrderId = @Id
	END
	ELSE IF(@TransactionTypeID =5) -- Order Approval
	BEGIN
		SET @Id = JSON_VALUE(@rawData, '$.OrderId');

		SELECT 
			OD.OrderDetailId,
			OD.OrderId,
			OD.ItemCode,
			OD.ItemName,
			OD.Price,
			OD.Qty,
			OD.Discount,
			OD.DiscountType,
			OD.IsDiscount
		FROM
		[dbo].[SPO_OrderDetails] OD
		WHERE OD.OrderId = @Id
	END
END

GO

