-- =============================================
-- Author:		Nivesh
-- Create date: 2025-10-22
-- Description:	Get Taken Basis Meal Count
-- =============================================
CREATE     PROCEDURE [dbo].[POS_spGetTakenBasisMealCount]
@HotelReservationNo VARCHAR(100),
@MealCode VARCHAR(1),
@RoomID INT,
@PropertyID INT
AS
SET NOCOUNT ON
BEGIN TRY
	BEGIN TRAN

	DECLARE @ReservedCount INT = 0
	SELECT @ReservedCount = ISNULL(SUM(BMT.Pax),0) 
        FROM [dbo].[BasisMealTemp] BMT 
        WHERE BMT.HotelReservationNo = @HotelReservationNo 
        AND BMT.MealCode = @MealCode
        AND BMT.RoomID = @RoomID
		AND BMT.PropertyId = @PropertyID
        GROUP BY BMT.HotelReservationNo,BMT.MealCode

	SELECT @ReservedCount AS ReservedCount
	
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

