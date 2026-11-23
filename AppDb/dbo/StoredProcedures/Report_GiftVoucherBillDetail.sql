-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC Report_GiftVoucherBillDetail '00049','T01','28/03/2025',1
CREATE PROCEDURE [dbo].[Report_GiftVoucherBillDetail]
	@OrderNo VARCHAR(10),
	@Outlet	 VARCHAR(10),
	@OrderDate VARCHAR(20),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT      
	L.description As Outlet, 
	SaleDate AS OrderDate,
	SysDate AS OrderTime,
	SaleOrderNo AS OrderNo,
	CONCAT(TypePrefix,'-',Amount) AS Description,
	Amount,
	1 AS Qty,
	Amount*1 as TotalAmount
	FROM            POS_GiftVoucher GV
	INNER JOIN Location_Ref L ON L.code = GV.SaleOutlet AND L.PropertyId = GV.PropertyId
	INNER JOIN POS_GiftVoucherHeader GH ON GH.DocNo = GV.SaleOrderNo AND GH.PropertyId = GV.PropertyId AND GV.SaleDate = GH.DocDate AND GV.SaleOutlet = GH.Outlet
	WHERE GV.SaleOutlet = @Outlet  AND GV.PropertyId=@PropertyId   AND GV.SaleOrderNo = @OrderNo
	GROUP BY  SaleDate,SaleOrderNo,TypePrefix,Amount,L.description,SysDate


    
END

GO

