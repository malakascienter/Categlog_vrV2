
CREATE PROCEDURE [dbo].[SP_BillVoid] 
	@OrderNo	VARCHAR(10),
	@PropertyId	INT,
	@Outlet	VARCHAR(10),
	@OrderDate	DATETIME,
	@UserId	VARCHAR(20),
	@VoidRemark nvarchar(250)
AS
BEGIN
DECLARE	@ErrorSave INT    
SET NOCOUNT ON;

 BEGIN TRY
 BEGIN TRANSACTION InProc


 DECLARE @UserName VARCHAR(20)
 SELECT TOP 1 @UserName = Username   FROM CentralAccessDB..Central_Users WHERE Id = @UserId
 SET @UserName = ISNULL(@UserName,'NA')


 INSERT INTO [dbo].[VoidBillHeader]
           ([PropertyId]
           ,[OrderNo]
           ,[OrderDate]
           ,[OrderTime]
           ,[TableNo]
           ,[Waiter]
           ,[OrderType]
           ,[Subtotal]
           ,[Discount]
           ,[ServiceCharge]
           ,[TaxType1]
           ,[TaxVal1]
           ,[TaxType2]
           ,[TaxVal2]
           ,[TaxType3]
           ,[TaxVal3]
           ,[TaxType4]
           ,[TaxVal4]
           ,[PackingCharge]
           ,[UserID]
           ,[Outlet]
           ,[SUS_SeqNo]
           ,[SUS_Date]
           ,[StartTime]
           ,[EndTime]
           ,[ComputerName]
           ,[BumpStart]
           ,[BumpEnd]
           ,[Upload]
           ,[GLPosting]
           ,[DiscountUsreId]
           ,[UpLoadDayEnd]
           ,[DisCode]
           ,[CPUread]
           ,[ManagerUserID]
           ,[subtype]
           ,[DeliveryCharge]
           ,[CustID]
           ,[RefNo]
           ,[DiscountedValue]
           ,[GESId]
           ,[IsGESRedeemed]
           ,[GESCode]
           ,[Validationcode]
           ,[Pax]
           ,[DriveStatus]
           ,[DocNo]
           ,[Remarks]
           ,[CompCode]
           ,[DiscRemarks]
           ,[ReservationNo]
           ,[POSNo]
           ,[IsBillDiscount1]
           ,[IsBump]
           ,[OrderBumpTime]
           ,[OGFUpload]
           ,[MemberID]
           ,[MemberName]
           ,[ContactNo]
           ,[CustomerName]
           ,[DeliveryAddress1]
           ,[DeliveryAddress2]
           ,[Landmark]
           ,[Remark]
           ,[TDL]
           ,[RoomID]
           ,[RoomName]
           ,[GuestProfileID]
           ,[MealPlanID]
           ,[MealEntitlement]
           ,[AggregatorID]
           ,[AggregatorPercentage]
           ,[TravelAgentID]
           ,[TravelAgentName]
           ,[ComplimentaryID]
           ,[HotelReservationNo]
		   ,[GuestProfileName]
		   ,[RoomPostingDocNo]
           ,[VoidUserID]
           ,[VoidUserDate]
           ,[IsBillDiscount]
           ,[VoidRemark])
		SELECT [PropertyId]
		      ,[OrderNo]
		      ,[OrderDate]
		      ,[OrderTime]
		      ,[TableNo]
		      ,[Waiter]
		      ,[OrderType]
		      ,[Subtotal]
		      ,[Discount]
		      ,[ServiceCharge]
		      ,[TaxType1]
		      ,[TaxVal1]
		      ,[TaxType2]
		      ,[TaxVal2]
		      ,[TaxType3]
		      ,[TaxVal3]
		      ,[TaxType4]
		      ,[TaxVal4]
		      ,[PackingCharge]
		      ,[UserID]
		      ,[Outlet]
		      ,[SUS_SeqNo]
		      ,[SUS_Date]
		      ,[starttime]
		      ,[endtime]
		      ,[ComputerName]
		      ,[BumpStart]
		      ,[BumpEnd]
		      ,[Upload]
		      ,[GLPosting]
		      ,[DiscountUsreId]
		      ,[UpLoadDayEnd]
		      ,[discode]
		      ,[CPUread]
		      ,[ManagerUserID]
		      ,[subtype]
		      ,[DeliveryCharge]
		      ,[CustID]
		      ,[REFNO]
		      ,[DiscountedValue]
		      ,[GESId]
		      ,[IsGESRedeemed]
		      ,[GESCode]
		      ,[Validationcode]
		      ,[pax]
		      ,[drivestatus]
		      ,[docNo]
		      ,[Remarks]
		      ,[compcode]
		      ,[DiscRemarks]
		      ,[ReservationNo]
		      ,[POSNo]
		      --,[NetAmount]
		      ,[IsBillDiscount]
		      ,[IsBump]
		      ,[OrderBumpTime]
		      ,[OGFUpload]
		      ,[MemberID]
		      ,[MemberName]
		      ,[ContactNo]
		      ,[CustomerName]
		      ,[DeliveryAddress1]
		      ,[DeliveryAddress2]
		      ,[Landmark]
		      ,[Remark]
		      ,[TDL]
		      ,[RoomID]
		      ,[RoomName]
		      ,[GuestProfileID]
		      ,[MealPlanID]
		      --,[MealPlanName]
		      ,[MealEntitlement]
		      ,[AggregatorID]
		      ,[AggregatorPercentage]
		      ,[TravelAgentID]
		      ,[TravelAgentName]
		      ,[ComplimentaryID]
		      ,[HotelReservationNo]
		      ,[GuestProfileName]
			  ,[RoomPostingDocNo]
			  ,@UserName
			  ,getdate()
			  ,0
			  ,@VoidRemark
		  FROM [dbo].[BillHeader]
		  WHERE [PropertyId] = @PropertyId AND [Outlet] = @Outlet AND  convert(date,[OrderDate]) = convert(date,@OrderDate) AND [OrderNo] = @OrderNo

		  DELETE FROM BillHeader
		  WHERE [PropertyId] = @PropertyId AND [Outlet] = @Outlet AND  convert(date,[OrderDate]) = convert(date,@OrderDate) AND [OrderNo] = @OrderNo

		  INSERT INTO [dbo].[VoidBillTrans]
           ([PropertyId]
           ,[OrderNo]
           ,[OrderType]
           ,[OrderDate]
           ,[OrderTime]
           ,[Category]
           ,[MainMenuCode]
           ,[Qty]
           ,[Rate]
           ,[DisCode]
           ,[DisPerc]
           ,[ItWiseDiscount]
           ,[UserID]
           ,[Outlet]
           ,[UniqueNo]
           ,[UploadDayEnd]
           ,[ItemCost]
           ,[CompCode]
           ,[ItemSeq]
           ,[RefItemCode]
           ,[SortSeq]
           ,[IsModifier]
           ,[ActionID]
           ,[IsCombo]
           ,[IsActionable]
           ,[ActualPrice]
           ,[ResNetVal]
           ,[IsInstruction]
           --,[ResNo]
		   )
		   SELECT 
		   [PropertyId]
		  ,[OrderNo]
		  ,[OrderType]
		  ,[OrderDate]
		  ,[OrderTime]
		  ,[Category]
		  ,[MainMenuCode]
		  ,[Qty]
		  ,[Rate]
		  ,[DisCode]
		  ,[DisPerc]
		  ,[ItWiseDiscount]
		  ,[UserID]
		  ,[Outlet]
		  ,[UniqueNo]
		  ,[UploadDayEnd]
		  ,[ItemCost]
		  ,[CompCode]
		  ,[ItemSeq]
		  ,[RefItemCode]
		  ,[SortSeq]
		  ,[IsModifier]
		  ,[ActionID]
		  ,[IsCombo]
		  ,[IsActionable]
		  ,[ActualPrice]
		  ,[ResNetVal]
		  --,[NetAmount]
		  ,[IsInstruction]
		  FROM BillTrans
		  WHERE [PropertyId] = @PropertyId AND [Outlet] = @Outlet AND  convert(date,[OrderDate]) = convert(date,@OrderDate) AND [OrderNo] = @OrderNo

		  DELETE FROM BillTrans
		  WHERE [PropertyId] = @PropertyId AND [Outlet] = @Outlet AND  convert(date,[OrderDate]) = convert(date,@OrderDate) AND [OrderNo] = @OrderNo


		  INSERT INTO [dbo].[VoidPayTrans]
           ([PropertyId]
           ,[OrderNo]
           ,[OrderDate]
           ,[PayCode]
           ,[Total]
           ,[Tendered]
           ,[ActualAmt]
           ,[Remark]
           ,[UserID]
           ,[OrderTime]
           ,[Outlet]
           ,[pin]
           ,[compcode]
           ,[ShiftID]
           ,[RoundingDifference])
		   SELECT [PropertyId]
      ,[OrderNo]
      ,[OrderDate]
      ,[PayCode]
      ,[Total]
      ,[Tendered]
      ,[ActualAmt]
      ,[Remark]
      ,[UserID]
      ,[OrderTime]
      ,[Outlet]
      ,[pin]
      ,[compcode]
      ,[ShiftID]
      ,[RoundingDifference]
  FROM [dbo].[PayTrans]
   WHERE [PropertyId] = @PropertyId AND [Outlet] = @Outlet AND  convert(date,[OrderDate]) = convert(date,@OrderDate) AND [OrderNo] = @OrderNo

    DELETE FROM [PayTrans]
	WHERE [PropertyId] = @PropertyId AND [Outlet] = @Outlet AND  convert(date,[OrderDate]) = convert(date,@OrderDate) AND [OrderNo] = @OrderNo

  IF @@TRANCOUNT > 0 
            BEGIN
                COMMIT TRANSACTION InProc;
                SELECT  1 AS Result
            END
     
        ELSE
            BEGIN
                SELECT  0 AS Result
            END

 END TRY  
     
	BEGIN CATCH
        IF @@TRANCOUNT > 0 
            BEGIN
                ROLLBACK TRANSACTION
                 SELECT  0 AS Result

            END
        ELSE 
            BEGIN
                 SELECT  0 AS Result
            END
    END CATCH



END

GO

