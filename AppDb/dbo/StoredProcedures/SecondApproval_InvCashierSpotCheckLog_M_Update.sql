
CREATE  PROCEDURE [dbo].[SecondApproval_InvCashierSpotCheckLog_M_Update]  
    @SpotCheckJson VARCHAR(MAX),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	SELECT ID,SecondApprovalRemark,SpotCheckNo,LocationID,ShiftDateStr
	INTO #TempSpotCheck
	FROM OPENJSON(@SpotCheckJson)
	WITH 
	(
		ID INT '$.ID',
		SecondApprovalRemark VARCHAR(200) '$.SecondApprovalRemark',
		SpotCheckNo INT '$.SpotCheckNo',
		LocationID INT '$.LocationID',
		ShiftDateStr VARCHAR(10) '$.ShiftDateStr'
	)

	

	UPDATE S
	SET S.IsSecondApproval = 1,
	    S.SecondApprovalRemark = T.SecondApprovalRemark,
		S.SecondApprovalDateTime = GETDATE(),
		S.SecondApprovalUser = @UserId
	from CashierDetail S INNER JOIN #TempSpotCheck T ON  S.LocationID = T.SpotCheckNo 
	where S.PropertyId = @PropertyId


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

