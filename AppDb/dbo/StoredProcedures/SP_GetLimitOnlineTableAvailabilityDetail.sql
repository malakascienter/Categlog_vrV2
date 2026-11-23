-- =============================================
-- Author:		Nivesh
-- Create date: 2024-05-30
-- Description:	Get Limit Online Table Availability
-- =============================================
-- EXEC [SP_GetLimitOnlineTableAvailabilityDetail] '2024-05-30','001',2,1
CREATE PROCEDURE [dbo].[SP_GetLimitOnlineTableAvailabilityDetail] 
	 @ResDate		DATE, 
	 @Outlet		VARCHAR(3),
	 @PropertyId	INT,
	 @TimeSlot		INT
AS
BEGIN

	SET NOCOUNT ON;


	BEGIN TRY 
	IF OBJECT_ID(N'tempdb..#TEMPTABLE') IS NOT NULL
	BEGIN
	DROP TABLE #TEMPTABLE
	END

	SELECT (MaxPaxLimit - ISNULL((SELECT SUM(TRT.NoOfPacks) FROM Reservation TRT WHERE TRT.IsCancel = 0 AND TRT.ReservationDate = @ResDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = @TimeSlot AND TRT.TableCategoryID = TCL.TableCategoryID ),0))   AS AvailablePaxCount,
	ISNULL((SELECT SUM(TRT.NoOfPacks) FROM Reservation TRT WHERE TRT.IsCancel = 0  AND TRT.ReservationDate = @ResDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = @TimeSlot AND TRT.TableCategoryID = TCL.TableCategoryID ),0) AS NoOfPacks,
	TCL.MaxPaxLimit AS MaxPaxCount,TCL.TableCategoryID ,TCL.TableCategoryName,@TimeSlot AS TimeSlotID,
	TCL.IsRevolving, TCL.ColorCode, TCL.ShowMaxPaxCount,TCL.imagePath
	INTO #TEMPTABLE
	FROM POS_TableCategories TCL WHERE TCL.PropertyId = @PropertyId 

	SELECT * FROM #TEMPTABLE WHERE NoOfPacks>=ShowMaxPaxCount

	IF OBJECT_ID(N'tempdb..#TEMPTABLE') IS NOT NULL
	BEGIN
	DROP TABLE #TEMPTABLE
	END

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
			--Insert Error log
			INSERT INTO OnlineTableReservation_ErrorTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
			VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	END CATCH;
END

GO

