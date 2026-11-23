-- [dbo].[SP_InsertOnlineTableReservation] '<TableCategoryData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ReservatinDate>2024-04-10T00:00:00</ReservatinDate><TimeSlot>Lunch - 11:30 to 15:00</TimeSlot><TimeSlotID>1</TimeSlotID><TableCategoryName>BMICH</TableCategoryName><TableCategoryID>1</TableCategoryID><SalutationName>Mr</SalutationName><SalutationID>11</SalutationID><FullName>Kamal</FullName><ContactNo>111565625</ContactNo><ArrivalTime>12:49</ArrivalTime><NoOfAdults>2</NoOfAdults><NoOfkids>6</NoOfkids><NoOfInfants>2</NoOfInfants><PropertyID>2</PropertyID><OutletCode>001</OutletCode></TableCategoryData>'

CREATE PROCEDURE [dbo].[SP_InsertOnlineTableReservation]
@XMLDetails AS XML
AS

BEGIN
BEGIN  TRY
BEGIN TRANSACTION

DECLARE 
@ReservationNo INT,
@ReservationDate DATETIME,
@CustomerName VARCHAR(50),
@NoOfAdult INT,
@NoOfChild INT,
@NoOfInfant INT,
@Remark VARCHAR(200) ='',
@Username VARCHAR(20) = '',
@Outlet VARCHAR(3),
@ContactNo VARCHAR(50),
@TableID INT =0,
@TimeSlotID INT =0,
@TimeSlot VARCHAR(20),
@UserId INT =0 ,
@PropertyId INT =0,
@SalutationId INT =0,
@ArrivalTime VARCHAR(20),
@ReservationWiseTableJson VARCHAR(MAX),
@TableCategoryID  INT=0,
@TableCategoryName VARCHAR(20),
@SalutationName VARCHAR(20),
@Email VARCHAR(50),
@GivenRate MONEY =0,
@ReservationStatusID INT --Added by Nivesh 2024-05-28

----------------------------------------------------------------------
    DECLARE @iDocID INT;

	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


	SELECT @ReservationDate = ReservatinDate,
			@TimeSlot = TimeSlot,
			@TimeSlotID = TimeSlotID,
			@TableCategoryName = TableCategoryName,
			@TableCategoryID = TableCategoryID,
			@SalutationName = SalutationName,
			@SalutationId = SalutationID,
			@CustomerName = FullName,
			@ContactNo = ContactNo,
			@ArrivalTime = ArrivalTime,
			@NoOfAdult = NoOfAdults,
			@NoOfChild = NoOfkids,
			@NoOfInfant = NoOfInfants,
			@PropertyID = PropertyID,
			@Outlet = OutletCode,
			@Email = Email,
			@ReservationStatusID = ReservationStatusID
	FROM
		OPENXML(@iDocID, '/TableCategoryData', 2)
		WITH
		(
			ReservatinDate DATETIME,
			TimeSlot VARCHAR(20),
			TimeSlotID INT,
			TableCategoryName VARCHAR(20),
			TableCategoryID INT,
			SalutationName VARCHAR(20),
			SalutationID INT,
			FullName VARCHAR(50),
			ContactNo VARCHAR(20),
			ArrivalTime TIME,
			NoOfAdults INT,
			NoOfkids INT,
			NoOfInfants INT,
			PropertyID INT,
			OutletCode VARCHAR(20),
			Email VARCHAR(50),
			ReservationStatusID INT
		);
----------------------------------------------------------------------

IF( @NoOfAdult <= 0)  
BEGIN
	RAISERROR ('No of adult should be gether than 0.!',16,1)   
END

DECLARE @CurrentPaxCount INT
SET @CurrentPaxCount = ISNULL((SELECT SUM(NoOfPacks) FROM Reservation TRT WHERE TRT.IsCancel = 0 AND TRT.ReservationDate = @ReservationDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = @TimeSlotID AND TRT.TableCategoryID = @TableCategoryID),0)

DECLARE @ReservationCurrentPaxCount INT
SET @ReservationCurrentPaxCount = ISNULL((SELECT SUM(NoOfPacks) FROM Reservation TRT WHERE TRT.IsCancel = 0 AND TRT.PropertyId = @PropertyId AND  TRT.ReservationNo =  @ReservationNo AND TRT.TableCategoryID = @TableCategoryID),0)

IF( ((@NoOfAdult+@NoOfChild)+(ISNULL(@CurrentPaxCount,0)-ISNULL(@ReservationCurrentPaxCount,0))) >  ISNULL((SELECT TOP(1) MaxPaxLimit FROM POS_TableCategories WHERE TableCategoryID = @TableCategoryID),0))  
BEGIN
	RAISERROR ('Max pax count cannot be exceed!',16,1)   
END


DECLARE @CurrentTableCategoryID INT

SELECT @CurrentTableCategoryID = TableCategoryID FROM Reservation WHERE ReservationNo =  @ReservationNo


IF( @CurrentTableCategoryID <> @TableCategoryID )
BEGIN

 DELETE FROM ReservationWiseTable WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId

END


IF EXISTS (SELECT ReservationNo FROM Reservation WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId)
	BEGIN
		UPDATE Reservation SET ReservationDate = @ReservationDate, CustomerName = @CustomerName, NoOfPacks = (@NoOfAdult+@NoOfChild),NoOfAdult =@NoOfAdult ,NoOfChild =  @NoOfChild,NoOfInfant = @NoOfInfant,
		Remark = @Remark,EditedUser = @Username, EditedDate = GETDATE(), ContactNo = @ContactNo, TableID = @TableID , TimeSlotID = @TimeSlotID,IsUpload = 0,SalutationId = @SalutationId,ArrivalTime =  CONVERT(time(7), @ArrivalTime),
		TableCategoryID = @TableCategoryID,GivenRate =@GivenRate, Email =@Email, ReservationStatusID = @ReservationStatusID, ReservationStatus =(SELECT TOP 1 Status FROM ReservationStatus WHERE ID =@ReservationStatusID), ChannelType = 'O'
		WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId
	END
ELSE
	BEGIN
	    SET @ReservationNo = CONVERT(INT,[dbo].[GetNextDocNo]('TblResNo',@PropertyId))
		EXEC [UpdateNextDocNo] 'TblResNo',@PropertyId
		INSERT INTO Reservation(ReservationNo, ReservationDate, CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, Remark,CreateUser,CreateDate,Outlet, ContactNo, TableID, TimeSlotID,PropertyId,IsUpload,
		SalutationId,ArrivalTime,TableCategoryID,GivenRate,Email,ReservationStatusID,ReservationStatus,ChannelType)
		VALUES(@ReservationNo,@ReservationDate,@CustomerName,(@NoOfAdult+@NoOfChild),@NoOfAdult,@NoOfChild,@NoOfInfant,@Remark,@Username,GETDATE(),@Outlet, @ContactNo, @TableID, @TimeSlotID,@PropertyId,
		0,@SalutationId,CONVERT(time(7), @ArrivalTime),@TableCategoryID,@GivenRate,@Email,@ReservationStatusID,(SELECT TOP 1 Status FROM ReservationStatus WHERE ID =@ReservationStatusID),'O')

		 
	END

--SELECT * FROM Reservation WHERE ReservationNo = @ReservationNo  AND PropertyId = @PropertyId 
	--------------------------------Get reservation data----------------------------------
	--SELECT ReservationNo, ReservationDate,CustomerName,NoOfPacks,AdvanceAmount,Remark,OrderNo,IsCancel ,IsComplete,CreateUser,CreateDate,EditedUser,EditedDate,CancelUser,CancelDate,Outlet,IsUpload,IsOnGoing
	--,ContactNo,TableID,NoOfAdult,NoOfChild,NoOfInfant,TimeSlotID,PropertyId,SalutationId
	--,ArrivalTime
	--,TableCategoryID,GivenRate,Email
	--FROM Reservation WHERE ReservationNo = @ReservationNo  AND PropertyId = @PropertyId 
	--------------------------------------------------------------------------------------
		SELECT 
		R.ReservationNo, R.ReservationDate, R.CustomerName, R.NoOfPacks, R.AdvanceAmount, R.Remark, R.OrderNo, R.IsCancel, R.IsComplete, R.CreateUser, R.CreateDate, R.EditedUser, R.EditedDate, R.CancelUser,
		R.CancelDate, R.Outlet, R.IsUpload, R.IsOnGoing, R.ContactNo, R.TableID, R.NoOfAdult, R.NoOfChild, R.NoOfInfant, R.TimeSlotID, R.PropertyId, R.SalutationId, R.ArrivalTime, R.TableCategoryID, R.GivenRate, 
		R.Email,
		COALESCE(
			(SELECT TOP 1 S.Name 
			 FROM Salutations S 
			 WHERE S.id = R.SalutationId AND S.PropertyId = R.PropertyId),
			''
		) AS SaluationName,
		COALESCE(
			(SELECT TOP 1 T.TableCategoryName 
			 FROM POS_TableCategories T 
			 WHERE T.TableCategoryID = R.TableCategoryID),
			''
		) AS TableCategoryName,
		COALESCE(
			(SELECT TOP 1 (RT.Description + ' - ' + LEFT(CONVERT(TIME, RT.FromTime),5) + ' to ' + LEFT(CONVERT(TIME, RT.ToTime),5)) AS Description 
			 FROM POS_ReservationTimeSlot RT 
			 WHERE RT.timeslotid = R.TimeSlotID),
			''
		) AS TimeSlotName,
		COALESCE(
			(SELECT TOP 1 C.Name 
			 FROM Companies C 
			 WHERE C.CompanyID = R.PropertyId),
			''
		) AS PropertyName
	FROM Reservation R 
	WHERE R.ReservationNo = @ReservationNo  AND R.PropertyId = @PropertyId

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	--Insert Error log
	INSERT INTO OnlineTableReservation_ErrorTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
	VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())	
	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)

END CATCH
END

GO

