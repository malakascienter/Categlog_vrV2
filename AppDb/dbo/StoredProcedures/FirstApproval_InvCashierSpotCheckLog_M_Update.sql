
CREATE  PROCEDURE [dbo].[FirstApproval_InvCashierSpotCheckLog_M_Update]  
    @SpotCheckJson VARCHAR(MAX),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	SELECT ID,FirstApprovalRemark,SpotCheckNo,LocationID,ShiftDateStr
	INTO #TempSpotCheck
	FROM OPENJSON(@SpotCheckJson)
	WITH 
	(
		ID INT '$.ID',
		FirstApprovalRemark VARCHAR(200) '$.FirstApprovalRemark',
		SpotCheckNo INT '$.SpotCheckNo',
		LocationID INT '$.LocationID',
		ShiftDateStr VARCHAR(10) '$.ShiftDateStr'
	)

	

	UPDATE S
	SET S.IsFirstApproval = 1,
	    S.FirstApprovalRemark = T.FirstApprovalRemark,
		S.FirstApprovalDateTime = GETDATE(),
		S.FirstApprovalUser = @UserId
	from CashierDetail S INNER JOIN #TempSpotCheck T ON S.CashierHeaderID = T.SpotCheckNo
	where S.PropertyId = @PropertyId




-----SEND EMAIL TO SECOND APPROVAL USER

		DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX),@OutletName VARCHAR(50),@ShiftDate DATE,@UserName VARCHAR(20),@SpotCheckNo INT

		select top(1) @OutletName = l.Name,@ShiftDate = s.BussinessDate, @SpotCheckNo = S.CashierHeaderID
		FROM CashierDetail S INNER JOIN #TempSpotCheck T ON S.CashierHeaderID = T.SpotCheckNo
		inner join Locations l on s.LocationID = l.Id and s.PropertyId = l.PropertyId
		where s.PropertyId = @PropertyId

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
				AND MenuItemId = 822 
				UNION
				SELECT 
				CU.Email
				FROM
				CentralAccessDB..[Central_UserRoleWiseMenuItems] AS URWP	
				INNER JOIN CentralAccessDB..Central_UserWiseUserRoles AS UWR ON UWR.UserRoleId = URWP.UserRoleId
				INNER JOIN CentralAccessDB..Central_Users CU ON UWR.UserId = CU.Id
				WHERE URWP.ModuleId=3 
				AND  URWP.MenuItemId = 822 
			) A

		SELECT @Email = STRING_AGG(Email, ';')  FROM #TempEmail

		SET @EmailBody = '<html><body><p>You have to respond a pending approval</p>
					  <table border = 1>
					  <thead>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Approval type</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Inventory Cashier Spot Check No</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Shift Date</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >Location Name</th>
						  <th  style="width: 20%;border-style: double;text-align: center;" >First Level Approved By</th>
					  </thead>
					  <tbody >
						<tr>
						 <td  style="width: 20%;border-style: double;text-align: center;" >Spot Check</td>
						 <td  style="width: 20%;border-style: double;text-align: center;" >'+CONVERT(varchar(max),ISNULL(@SpotCheckNo,0))+'</td>
						 <td  style="width: 20%;border-style: double;text-align: center;" >'+CONVERT(varchar(max),ISNULL(@ShiftDate,GETDATE()))+'</td>
						 <td  style="width: 20%;border-style: double;text-align: center;" >'+ISNULL(@OutletName,'')+'</td>
						  <td  style="width: 20%;border-style: double;text-align: center;" >'+ISNULL(@UserName,'')+'</td>
                        </tr>
					  </tbody>
					  </table></html></body>'
	--SET @Email = 'dilshang@scienter.lk'
	IF @Email IS NOT NULL AND @Email <> ''
	BEGIN

	 EXEC [dbo].[SendPOSBackendMain] @Email, 'Pending Spot Check Approval', @EmailBody


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

