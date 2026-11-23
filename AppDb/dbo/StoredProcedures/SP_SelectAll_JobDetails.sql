-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 06 JUNE 2023
-- Description:	SELECT JOB WISE DOCUMENT
-- [dbo].[SP_SelectAll_JobDetails] 4,34,-999
-- =============================================
Create PROCEDURE [dbo].[SP_SelectAll_JobDetails]
(
	@PropertyID int,
	@RequestHeaderID int,
	@locationID INT=0
)
AS
BEGIN
	SET NOCOUNT ON;

	
		DECLARE @stockItemID INT,
		@stockItemCode varchar(50),
		@ApprovedQty decimal(18,6),
		@RequestedQuantity DECIMAL(18,6),
		@UnitPrice DECIMAL(18,6),
		@UnitID INt,
		@BalanaceQty decimal(18,6),
		@JobLocationID int,
		@JobLocationName Varchar(200),
		@SupplierID INT,
		@SupplierName VARCHAR(500),
		@SuppCostPrice money,
		@RemainQty decimal(18,6)

		CREATE TABLE #TempQuantityInhand
		(
			Quantity decimal(18,6),
			StockItemId INT,
			StockItemCode varchar(50),
			JobHeaderID INT,
			ApprovedQty decimal(18,6),
			RequestedQuantity DECIMAL(18,6),
			UnitPrice DECIMAL(18,6),
			UnitID INT,
			BalanceQty decimal(18,6),
			Supplier VARCHAR(500),
			SupplierID INT,
			CostPrice money,
			RemainQty decimal(18,6)


		)

		select *
		INTO #TempJobExDetails
		FROM JobExDetails JX
		WHERE JX.JobHeaderID= @RequestHeaderID

		SELECT *
		INTO #TempJobWiseMeterialList
		FROM JobWiseMeterialList JM
		WHERE JM.JobHeaderID= @RequestHeaderID

		select @RemainQty = Qty-ReservedQty
		from #TempJobWiseMeterialList

		SELECT *
		INTO #JobStockAllocation 
		FROM JobStockAllocation JA
		WHERE JA.JobHeaderID= @RequestHeaderID 

		WHILE EXISTS(SELECT 1 FROM #TempJobExDetails)
		BEGIN
		
			SELECT  @stockItemID = JX.StockItemID,@stockItemCode = StockItemCode
			FROM #TempJobExDetails JX
			WHERE JX.JobHeaderID= @RequestHeaderID

			SELECT @BalanaceQty = sum(JA.BalanceQty),@JobLocationID = JA.LocationId
			FROM #JobStockAllocation JA
			WHERE JA.StockItemId = @stockItemID
			group by JA.BalanceQty,JA.LocationId

			SELECT @JobLocationName =Name
			FROM LOCATIONS
			WHERE Id=@JobLocationID
		

			SELECT @ApprovedQty = sum(ApprovedQuantity),@RequestedQuantity = SUM(RequestedQuantity),@UnitPrice = UnitPrice,@UnitID = UnitID
			from #TempJobExDetails
			where StockItemID=@stockItemID
			GROUP BY UnitPrice,UnitID


			SELECT TOP(1)@SupplierID = SupplierID,@SuppCostPrice= CostPrice
			FROM SupplierWiseItemDetails
			WHERE StockItemID = @stockItemID 


			SELECT @SupplierName = Name
			FROM suppliers
			where ID =@SupplierID

			DELETE  FROM #TempJobExDetails where StockItemID=@stockItemID 

	--select @PropertyID,@locationID,@stockItemID

			INSERT INTO  #TempQuantityInhand(Quantity,StockItemId,StockItemCode,JobHeaderID,ApprovedQty,RequestedQuantity,UnitPrice,UnitID,BalanceQty,Supplier,SupplierID,CostPrice,RemainQty)
			SELECT dbo.FN_GetStockInHand(@PropertyID,@locationID,@stockItemID) QuantityInHand,@stockItemID,@stockItemCode,@RequestHeaderID,@ApprovedQty,@RequestedQuantity,@UnitPrice,@UnitID,@BalanaceQty,@SupplierName,@SupplierID,@SuppCostPrice,@RemainQty

			
		END

		--SELECT *
		--FROM #TempQuantityInhand
		
		DROP TABLE #TempJobExDetails

		DROP TABLE #JobStockAllocation

		select  SH.StockItemCode,@JobLocationID LocationID,JH.Id AS RequestHeaderID,SH.Id  AS RequestDetailID,SH.StockItemCode,
		U.Code AS UnitCode,TQ.UnitPrice,JH.DocumentNo , TQ.RemainQty ApprovedQuantity,TQ.RequestedQuantity,
		JH.CreatedDate RequestDate,JH.Remarks Remarks,JH.DocumentStatus,SH.Id AS StockItemHeaderID, U.Id AS UnitID,
		SH.IsExpiryDateApplicable,UM.UserName AS RequestedUser,
		SH.Name AS ItemName,U.Name AS UnitName,TQ.StockItemId StockItemID,TQ.Quantity+TQ.BalanceQty QtyInHand,@JobLocationName LocationName
		,TQ.Quantity,TQ.BalanceQty,TQ.Supplier,TQ.SupplierID,TQ.CostPrice
		from [dbo].[JobExHeaders] JH
		inner  join #TempQuantityInhand TQ ON JH.Id = TQ.JobHeaderID
		INNER JOIN StockItemHeaders SH ON TQ.StockItemId = SH.Id
		INNER JOIN Units U ON TQ.UnitID = U.Id
		LEFT JOIN UserMasters UM ON UM.Id = JH.UserProfileID
		where JH.id=@RequestHeaderID AND JH.DocumentStatus = 'P'
		AND JH.isApproved=1 AND TQ.BalanceQty >0
		

		DROP TABLE #TempQuantityInhand

		

END

GO

