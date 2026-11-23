
CREATE PROCEDURE [dbo].[POS_spInsertReservation]
@ReservationNo INT,
@ReservationDate DATETIME,
@CustomerName VARCHAR(50),
@NoOfAdult INT,
@NoOfChild INT,
@NoOfInfant INT,
@Remark VARCHAR(200),
@Username VARCHAR(20),
@Outlet VARCHAR(3),
@ContactNo VARCHAR(50),
@TableID INT,
@TimeSlotID INT,
@UserId INT,
@PropertyId INT,
@SalutationId INT,
@ArrivalTime VARCHAR(20),
@ReservationWiseTableJson VARCHAR(MAX),
@TableCategoryID  INT,
@GivenRate MONEY,
@ReservationStatusID INT
AS

BEGIN
BEGIN  TRY
BEGIN TRANSACTION


IF( @NoOfAdult <= 0)  
BEGIN
	RAISERROR ('No of adult should be gether than 0.!',16,1)   
END


DECLARE @ReservationStatus VARCHAR(15)
SELECT @ReservationStatus = Status FROM ReservationStatus WHERE ID  = @ReservationStatusID

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
		TableCategoryID = @TableCategoryID,GivenRate =@GivenRate,ReservationStatusID = @ReservationStatusID,ReservationStatus = ISNULL(@ReservationStatus,'')
		WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId
	END
ELSE
	BEGIN
	    SET @ReservationNo = CONVERT(INT,[dbo].[GetNextDocNo]('TblResNo',@PropertyId))
		EXEC [UpdateNextDocNo] 'TblResNo',@PropertyId
		INSERT INTO Reservation(ReservationNo, ReservationDate, CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, Remark,CreateUser,CreateDate,Outlet, ContactNo, TableID, TimeSlotID,PropertyId,IsUpload,SalutationId,ArrivalTime,TableCategoryID,GivenRate,ReservationStatusID,ChannelType,ReservationStatus)
		VALUES(@ReservationNo,@ReservationDate,@CustomerName,(@NoOfAdult+@NoOfChild),@NoOfAdult,@NoOfChild,@NoOfInfant,@Remark,@Username,GETDATE(),@Outlet, @ContactNo, @TableID, @TimeSlotID,@PropertyId,0,@SalutationId,CONVERT(time(7), @ArrivalTime),@TableCategoryID,@GivenRate,@ReservationStatusID,'B',ISNULL(@ReservationStatus,''))

		 
	END




	--DELETE FROM ReservationWiseTable  WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId 

	--INSERT INTO ReservationWiseTable(ReservationNo,TableID,PropertyId,CreateDate,CreateUserId)
	--SELECT @ReservationNo,TableID,@PropertyId,getdate(),@UserId
	--FROM OPENJSON(@ReservationWiseTableJson)  
	--WITH 
	--(		
	--	TableID  INT '$.TableID'
	--)
    
	--UPDATE Reservation
	--SET TableID =  ISNULL((SELECT TOP(1) TableID FROM ReservationWiseTable WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId ),0)
	--WHERE ReservationNo = @ReservationNo  AND PropertyId = @PropertyId 

SELECT * FROM Reservation WHERE ReservationNo = @ReservationNo  AND PropertyId = @PropertyId 

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH
END

GO

