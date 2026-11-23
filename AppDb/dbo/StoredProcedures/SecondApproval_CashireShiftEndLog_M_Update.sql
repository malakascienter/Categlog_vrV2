
CREATE  PROCEDURE [dbo].[SecondApproval_CashireShiftEndLog_M_Update]  
    @CashireShiftEndJson VARCHAR(MAX),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	SELECT ID,SecondApprovalRemark,ShiftNo,Outlet,ShiftDateStr
	INTO #TempCashireShiftEndLog
	FROM OPENJSON(@CashireShiftEndJson)
	WITH 
	(
		ID INT '$.ID',
		SecondApprovalRemark VARCHAR(200) '$.SecondApprovalRemark',
		ShiftNo VARCHAR(10) '$.ShiftNo',
		Outlet VARCHAR(3) '$.Outlet',
		ShiftDateStr VARCHAR(10) '$.ShiftDateStr'
	)

	

	UPDATE S
	SET S.IsSecondApproval = 1,
	    S.SecondApprovalRemark = T.SecondApprovalRemark,
		S.SecondApprovalDateTime = GETDATE(),
		S.SecondApprovalUser = @UserId
	from [POS_CashireShiftEndLog] S INNER JOIN #TempCashireShiftEndLog T ON S.ID = T.Id AND S.ShiftNo = T.ShiftNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103)
	where S.IsCash = 0 AND S.PropertyId = @PropertyId


	DECLARE @SecondApprovalRemark VARCHAR(200)
	DECLARE @ShiftNo VARCHAR(10)
	DECLARE @ShiftDateStr VARCHAR(10)

	SELECT @SecondApprovalRemark = T.SecondApprovalRemark,@ShiftNo = T.ShiftNo  ,@ShiftDateStr = T.ShiftDateStr
	FROM [POS_CashireShiftEndLog] S INNER JOIN #TempCashireShiftEndLog T ON S.ID = T.Id AND S.ShiftNo = T.ShiftNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103)
	where S.IsCash =1 AND S.PropertyId = @PropertyId

	UPDATE [POS_CashireShiftEndLog]
	SET IsSecondApproval = 1,
	    SecondApprovalRemark = @SecondApprovalRemark,
		SecondApprovalDateTime = GETDATE(),
		SecondApprovalUser = @UserId
	where IsCash = 1 AND ShiftNo = @ShiftNo AND PropertyId = @PropertyId AND ShiftDate = CONVERT(DATETIME,@ShiftDateStr,103)


COMMIT TRANSACTION		
END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

