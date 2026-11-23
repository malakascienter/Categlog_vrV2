-- =============================================
-- Author:		Chiraj
-- Create date: 2020-05-16
-- Description:	Save Item Breakown
-- =============================================
CREATE PROCEDURE [dbo].[SalesTarget_M_Save]
	@SalesTargetJson NVARCHAR(MAX),
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	SELECT * INTO #TempSalesTarget 
	FROM OPENJSON(@SalesTargetJson)
	WITH
	(
			Outlet VARCHAR(5) '$.Outlet',
			MonthNo VARCHAR(5)'$.MonthNo',
			YearNo VARCHAR(5)'$.YearNo',
			MonthYear VARCHAR(15)'$.MonthYear',
			SalesTarget MONEY'$.SalesTarget'
	)

	DECLARE @Outlet VARCHAR(5),@MonthNo VARCHAR(5),@YearNo VARCHAR(5)
	SELECT TOP(1) @Outlet = Outlet,@MonthNo = MonthNo,@YearNo = YearNo  FROM #TempSalesTarget

	DELETE FROM POS_SalesTarget 
	WHERE PropertyId = @PropertyId AND Outlet = @Outlet AND MonthNo = @MonthNo AND YearNo = @YearNo

	INSERT INTO POS_SalesTarget (Outlet,MonthNo,YearNo,MonthYear,SalesTarget,SysDate,PropertyId)
	SELECT Outlet,MonthNo,YearNo,MonthYear,SalesTarget,GETDATE() AS SysDate,@PropertyId FROM #TempSalesTarget 


COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR('Record Not Save.',16,1)
END CATCH

GO

