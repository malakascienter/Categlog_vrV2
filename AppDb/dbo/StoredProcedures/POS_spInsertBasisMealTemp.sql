
CREATE     PROCEDURE [dbo].[POS_spInsertBasisMealTemp](
  @XMLDetails NVARCHAR(MAX)
)
AS
BEGIN TRY
	BEGIN TRAN
		
        DECLARE @OrderDate DATETIME,
        @OrderTime DATETIME,
        @MealCode VARCHAR(1),
        @iDocID INT,
        @HeadCount INT,
        @ReservedCount INT,
        @PaxCount INT,
        @RemainCount INT,
        @HotelReservationNo NVARCHAR(50),
        @BreakfastAllowed INT = 0,
        @LunchAllowed INT = 0,
        @DinnerAllowed INT = 0,
        @RoomID INT
        
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

         CREATE TABLE #TempMealPlan(
	        [Pax] [int] NULL,
	        [HotelReservationNo] [varchar](20) NULL,
	        [RoomID] [int] NULL,
	        [RoomName] [varchar](50) NULL,
	        [GuestProfileID] [int] NULL,
	        [GuestProfileName] [varchar](500) NULL,
	        [MealPlanID] [int] NULL,
	        [MealPlanName] [varchar](200) NULL,
	        [PropertyId] [int] NULL,
	        [MealCode] [char](1) NULL,
	        [HeadCount] [int] NULL,
	        [BreakfastAllowed] [int] NULL,
	        [LunchAllowed] [int] NULL,
	        [DinnerAllowed] [int] NULL)
		
        SET @OrderTime = GETDATE()

		SET @MealCode = (SELECT MealCode FROM POS_MealSchedule WHERE	CONVERT(TIME,GETDATE()) BETWEEN CONVERT(TIME,FromTime) AND CONVERT(TIME,ToTime))
        
        INSERT INTO #TempMealPlan ( [Pax]
           ,[HotelReservationNo]
           ,[RoomID]
           ,[RoomName]
           ,[GuestProfileID]
           ,[GuestProfileName]
           ,[MealPlanID]
           ,[MealPlanName]
           ,[PropertyId]
           ,[MealCode]
           ,[HeadCount]
           ,[BreakfastAllowed]
           ,[LunchAllowed]
           ,[DinnerAllowed])
        SELECT 
            PaxCount AS [Pax]
           , ReservationNo AS [HotelReservationNo]
           ,[RoomID]
           ,[RoomName]
           ,[GuestProfileID]
           ,GuestName AS [GuestProfileName]
           ,MealPlanId AS [MealPlanID]
           ,[MealPlanName]
           ,[PropertyId]
           ,MealCode
           ,[HeadCount]
           ,[BreakfastAllowed]
           ,[LunchAllowed]
           ,[DinnerAllowed]
			FROM
            OPENXML(@iDocID, '/clsRoomList', 2)
            WITH (
            [PaxCount] [int] ,
	        [ReservationNo] [varchar](20),
	        [RoomID] [int] ,
	        [RoomName] [varchar](50) ,
	        [GuestProfileID] [int] ,
	        [GuestName] [varchar](500) ,
	        [MealPlanId] [int] ,
	        [MealPlanName] [varchar](200) ,
	        [PropertyId] [int] ,
	        [MealCode] [char](1) ,
	        [HeadCount] [int] ,
	        [BreakfastAllowed] [int] ,
	        [LunchAllowed] [int] ,
	        [DinnerAllowed] [int] 
            );
        
        --------------------------------Validation---------------------------------
        IF NOT EXISTS(SELECT 1 FROM #TempMealPlan)
        BEGIN
             RAISERROR('Provide meal data',16,1)
		     ROLLBACK TRANSACTION
        END
        ELSE
        BEGIN
            
            SELECT @HeadCount = HeadCount,
            @PaxCount = Pax,
            @HotelReservationNo = HotelReservationNo,
            @MealCode = MealCode,
            @BreakfastAllowed = BreakfastAllowed,
            @LunchAllowed = LunchAllowed,
            @DinnerAllowed = DinnerAllowed,
            @RoomID = RoomID
            FROM #TempMealPlan

            SELECT @ReservedCount = ISNULL(SUM(BMT.Pax),0) 
            FROM [dbo].[BasisMealTemp] BMT 
            WHERE BMT.HotelReservationNo = @HotelReservationNo 
            AND BMT.MealCode = @MealCode
            AND BMT.RoomID = @RoomID
            GROUP BY BMT.HotelReservationNo,BMT.MealCode

            IF(@MealCode = 'B' AND @BreakfastAllowed = 0)
            BEGIN
                RAISERROR('Breakfast not allowed',16,1)
		        ROLLBACK TRANSACTION
            END
            ELSE IF(@MealCode = 'L' AND @LunchAllowed = 0)
            BEGIN
                RAISERROR('Lunch not allowed',16,1)
		        ROLLBACK TRANSACTION
            END
            ELSE IF(@MealCode = 'D' AND @DinnerAllowed = 0)
            BEGIN
                RAISERROR('Dinner not allowed',16,1)
		        ROLLBACK TRANSACTION
            END

            IF(@HeadCount < @PaxCount)
            BEGIN
                RAISERROR('Invalid pax count',16,1)
		        ROLLBACK TRANSACTION
            END

            IF(@ReservedCount >= @HeadCount )
            BEGIN
                RAISERROR('Already over',16,1)
		        ROLLBACK TRANSACTION
            END

            IF(@PaxCount > (@HeadCount - @ReservedCount))
            BEGIN
                RAISERROR('Exceed pax count',16,1)
		        ROLLBACK TRANSACTION
            END
        END
       
        ----------------------------------------------------------------------------
		INSERT INTO [dbo].[BasisMealTemp]
           ([Pax]
           ,[HotelReservationNo]
           ,[RoomID]
           ,[RoomName]
           ,[GuestProfileID]
           ,[GuestProfileName]
           ,[MealPlanID]
           ,[MealPlanName]
           ,[PropertyId]
           ,[MealCode]
           ,[HeadCount]
           ,[BreakfastAllowed]
           ,[LunchAllowed]
           ,[DinnerAllowed])
         SELECT [Pax]
               ,[HotelReservationNo]
               ,[RoomID]
               ,[RoomName]
               ,[GuestProfileID]
               ,[GuestProfileName]
               ,[MealPlanID]
               ,[MealPlanName]
               ,[PropertyId]
               ,[MealCode]
               ,[HeadCount]
               ,[BreakfastAllowed]
               ,[LunchAllowed]
               ,[DinnerAllowed]
         FROM
         #TempMealPlan
          

		
	COMMIT TRAN 
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @Msg NVARCHAR(200)
	SET @Msg = ERROR_MESSAGE()
	INSERT INTO POS_DatabaseErrorLog (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),@Msg)
	RAISERROR(@Msg,16,1)
END CATCH

GO

