
CREATE  PROCEDURE [dbo].[SecondApproval_SpotCheck_M_Update]  
    @SpotCheckJson VARCHAR(MAX),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	SELECT ID,SecondApprovalRemark,SpotCheckNo,Outlet,ShiftDateStr
	INTO #TempSpotCheck
	FROM OPENJSON(@SpotCheckJson)
	WITH 
	(
		ID INT '$.ID',
		SecondApprovalRemark VARCHAR(200) '$.SecondApprovalRemark',
		SpotCheckNo INT '$.SpotCheckNo',
		Outlet VARCHAR(3) '$.Outlet',
		ShiftDateStr VARCHAR(10) '$.ShiftDateStr'
	)

	

	UPDATE S
	SET S.IsSecondApproval = 1,
	    S.SecondApprovalRemark = T.SecondApprovalRemark,
		S.SecondApprovalDateTime = GETDATE(),
		S.SecondApprovalUser = @UserId
	from POS_SpotCheckLog S INNER JOIN #TempSpotCheck T ON S.ID = T.Id AND S.SpotCheckNo = T.SpotCheckNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103)
	where S.IsCash = 0 AND S.PropertyId = @PropertyId


	DECLARE @SecondApprovalRemark VARCHAR(200)
	DECLARE @SpotCheckNo INT
	DECLARE @ShiftDateStr VARCHAR(10)

	SELECT @SecondApprovalRemark = T.SecondApprovalRemark,@SpotCheckNo = T.SpotCheckNo  ,@ShiftDateStr = T.ShiftDateStr
	FROM POS_SpotCheckLog S INNER JOIN #TempSpotCheck T ON S.ID = T.Id AND S.SpotCheckNo = T.SpotCheckNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103)
	where S.IsCash =1 AND S.PropertyId = @PropertyId

	UPDATE POS_SpotCheckLog
	SET IsSecondApproval = 1,
	    SecondApprovalRemark = @SecondApprovalRemark,
		SecondApprovalDateTime = GETDATE(),
		SecondApprovalUser = @UserId
	where IsCash = 1 AND SpotCheckNo = @SpotCheckNo AND PropertyId = @PropertyId  AND ShiftDate = CONVERT(DATETIME,@ShiftDateStr,103)


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

