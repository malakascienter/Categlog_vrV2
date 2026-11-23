
CREATE  PROCEDURE [dbo].[FirstApproval_CashireShiftEndLog_M_Update]  
    @CashireShiftEndJson VARCHAR(MAX),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	SELECT ID,FirstApprovalRemark,ShiftNo,Outlet,ShiftDateStr
	INTO #TempCashireShiftEndLog
	FROM OPENJSON(@CashireShiftEndJson)
	WITH 
	(
		ID INT '$.ID',
		FirstApprovalRemark VARCHAR(200) '$.FirstApprovalRemark',
		ShiftNo VARCHAR(10) '$.ShiftNo',
		Outlet VARCHAR(3) '$.Outlet',
		ShiftDateStr VARCHAR(10) '$.ShiftDateStr'
	)

	

	UPDATE S
	SET S.IsFirstApproval = 1,
	    S.FirstApprovalRemark = T.FirstApprovalRemark,
		S.FirstApprovalDateTime = GETDATE(),
		S.FirstApprovalUser = @UserId
	from [POS_CashireShiftEndLog] S INNER JOIN #TempCashireShiftEndLog T ON S.ID = T.Id AND S.ShiftNo = T.ShiftNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103)
	where S.IsCash = 0 AND S.PropertyId = @PropertyId


	DECLARE @FirstApprovalRemark VARCHAR(200)
	DECLARE @ShiftNo VARCHAR(10)
	DECLARE @ShiftDateStr VARCHAR(10)

	SELECT @FirstApprovalRemark = T.FirstApprovalRemark,@ShiftNo = T.ShiftNo  ,@ShiftDateStr = T.ShiftDateStr
	FROM [POS_CashireShiftEndLog] S INNER JOIN #TempCashireShiftEndLog T ON S.ID = T.Id AND S.ShiftNo = T.ShiftNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103)
	where S.IsCash =1 AND S.PropertyId = @PropertyId

	UPDATE [POS_CashireShiftEndLog]
	SET IsFirstApproval = 1,
	    FirstApprovalRemark = @FirstApprovalRemark,
		FirstApprovalDateTime = GETDATE(),
		FirstApprovalUser = @UserId
	where IsCash = 1 AND ShiftNo = @ShiftNo AND PropertyId = @PropertyId AND ShiftDate = CONVERT(DATETIME,@ShiftDateStr,103)


-----SEND EMAIL TO SECOND APPROVAL USER

		DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX),@OutletName VARCHAR(50),@ShiftDate DATE,@UserName VARCHAR(20)

		select top(1) @OutletName = l.description,@ShiftDate = s.ShiftDate 
		FROM POS_CashireShiftEndLog S INNER JOIN #TempCashireShiftEndLog T ON S.ID = T.Id AND S.ShiftNo = T.ShiftNo AND S.ShiftDate = CONVERT(DATETIME,T.ShiftDateStr,103) and S.Outlet = T.Outlet
		inner join Location_Ref l on s.Outlet = l.code and s.PropertyId = l.PropertyId
		where s.ShiftNo = @ShiftNo AND s.PropertyId = @PropertyId AND s.ShiftDate = CONVERT(DATETIME,@ShiftDateStr,103)

		SELECT @UserName =  UserName FROM CentralAccessDB..Central_Users WHERE Id = @UserId 


		select Email
		into #TempEmail
		from (
				SELECT 
				B.Email
				FROM
				CentralAccessDB..[Central_UserWiseIndividualMenuItems] A INNER JOIN 
				CentralAccessDB..Central_Users B ON A.UserId = B.Id
				WHERE ModuleId=3 AND PropertyId=1
				AND MenuItemId = 824 
				UNION
				SELECT 
				CU.Email
				FROM
				CentralAccessDB..[Central_UserRoleWiseMenuItems] AS URWP	
				INNER JOIN CentralAccessDB..Central_UserWiseUserRoles AS UWR ON UWR.UserRoleId = URWP.UserRoleId
				INNER JOIN CentralAccessDB..Central_Users CU ON UWR.UserId = CU.Id
				WHERE URWP.ModuleId=3 
				AND  URWP.MenuItemId = 824 
			) A

		SELECT @Email = STRING_AGG(Email, ';')  FROM #TempEmail

		SET @EmailBody = '<html><body><p>You have to respond a pending approval</p>
					  <table border = 1>
					  <thead>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Approval type</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Shift No</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Shift Date</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Location Name</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >First Level Approved By</th>
					  </thead>
					  <tbody >
						<tr>
						 <td  style="width: 20%;border-style: double;text-align: center;" >Cashire Shift End</td>
						 <td  style="width: 20%;border-style: double;text-align: center;" >'+CONVERT(varchar(max),ISNULL(@ShiftNo,0))+'</td>
						 <td  style="width: 20%;border-style: double;text-align: center;" >'+CONVERT(varchar(max),ISNULL(@ShiftDate,GETDATE()))+'</td>
						 <td  style="width: 20%;border-style: double;text-align: center;" >'+ISNULL(@OutletName,'')+'</td>
						  <td  style="width: 20%;border-style: double;text-align: center;" >'+ISNULL(@UserName,'')+'</td>
                        </tr>
					  </tbody>
					  </table></html></body>'
	--SET @Email = 'dilshang@scienter.lk'
	IF @Email IS NOT NULL AND @Email <> ''
	BEGIN

	 EXEC [dbo].[SendPOSBackendMain] @Email, 'Pending Cashire Shift End Approval', @EmailBody


	END


-----SEND EMAIL TO SECOND APPROVAL USER


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

