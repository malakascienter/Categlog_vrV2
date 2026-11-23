
-- =============================================
-- Date: 2026-09-11
-- Description: Customer BSP Code becomes read-only once set. Follows script 35, which is
--              already deployed; the only change is the UPDATE of [CustomerBSPCode].
--              INSERT is unchanged. No C# or parameter change - safe to run on its own.
-- =============================================
-- created by S.G. Asanga Chandrakumara
-- ON9/28/2017 11:14:20 AM
-- Re modified By Nivesh 2024-02-19



CREATE PROCEDURE [dbo].[SP_Save_Departments]
 --DECLARE PARAMETERS

	@Id int,
	@LocationID int,
	@Code nvarchar(max),
	@Name nvarchar(max),
	@IsApplyForFO bit,
	@IsApplyForInv bit,
	@IsApplyForBan bit,
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] output,
	@PropertyID[int],
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT,
	@CustomerBSPCode varchar(max) = NULL

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM Departments WHERE  [Id] = @Id)
		BEGIN
			EXEC InsertMasterFileChangeLog 'Departments',@CreatedUserID,'U',@Name
			 --UPDATE THE RECORD
			 UPDATE Departments SET
			[LocationID] = @LocationID,
			[Code] = @Code,
			[Name] = @Name,
			[IsApplyForFO] = @IsApplyForFO,
			[IsApplyForInv] = @IsApplyForInv,
			[IsApplyForBan] = @IsApplyForBan,
			[IsActive] = @IsActive,
			[IPAddress] = @IPAddress,
			[LastModUserID] = @LastModUserID,
			[LastModDate] = @LastModDate,
			[PropertyID] = @PropertyID,
			-- Blank is stored as NULL so the franchise filter
			-- (NULLIF(LTRIM(RTRIM(CustomerBSPCode)),'') IS NOT NULL) stays consistent.
			--Modified 2026-09-11 - a BSP code is fixed once saved: an existing code is kept and
			--@CustomerBSPCode only fills a department that has none. Matches the read-only
			--dropdown on edit, and stops a save that sends NULL (e.g. franchise invoicing
			--switched off for the company) from wiping the code.
			[CustomerBSPCode] = ISNULL(NULLIF(LTRIM(RTRIM([CustomerBSPCode])), ''),
			                          NULLIF(LTRIM(RTRIM(@CustomerBSPCode)), ''))
			WHERE [Id] = @Id
			SET @statusIN = 2
			--Audit Log -- Added By Nivesh 2024-02-19
			EXEC Inventry_AuditTail_WriteToLog 'Departments', @Id, 'INV', 'DEPU', 'U', @LastModUserID,@PropertyID, '', ''
					----newly added 06.02.2024 
			IF(@LastModUserID = 0)
			BEGIN
				--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
				--RAISERROR ( @ErrorMsg2, 16, 1 ); 
				RAISERROR('User ID Invalid, Please Log In Again',16,1)
				ROLLBACK TRANSACTION
			END
		END
-----------------------------
	



	ELSE
	BEGIN
	EXEC InsertMasterFileChangeLog 'Departments',@CreatedUserID,'I',@Name
	--INSERT THE RECORD

	INSERT INTO Departments(
		[LocationID],
		[Code],
		[Name],
		[IsApplyForFO],
		[IsApplyForInv],
		[IsApplyForBan],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[PropertyID],
		[CustomerBSPCode]
		)
		VALUES
		(
		@LocationID,
		@Code,
		@Name,
		@IsApplyForFO,
		@IsApplyForInv,
		@IsApplyForBan,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@PropertyID,
		NULLIF(LTRIM(RTRIM(@CustomerBSPCode)), '')
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		--Audit Log -- Added By Nivesh 2024-02-19
		EXEC Inventry_AuditTail_WriteToLog 'Departments', @NewId, 'INV', 'DEPI', 'I', @LastModUserID,@PropertyID, '', ''
		SET @statusIN = 1;
	END
		----newly added 24.01.2024 
			IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------

	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
	    EXEC InsertMasterFileChangeLog 'Departments',@CreatedUserID,'D',@Name

		SELECT * INTO #temptable FROM (
		SELECT DISTINCT DepartmentId FROM DepartmentWiseItems WHERE DepartmentId = @Id
		UNION ALL
		SELECT DISTINCT DepartmentId FROM StockTransactionHeaders WHERE DepartmentId = @Id
		UNION ALL
		SELECT DISTINCT DepartmentId FROM RequestHeaders WHERE DepartmentId = @Id
		UNION ALL
		SELECT DISTINCT deptid DepartmentId FROM UserWiseDepartments WHERE deptid = @Id
		UNION ALL
		SELECT DISTINCT DepartmentId FROM DepartmentWiseCostProvisions WHERE DepartmentId = @Id
		) AS CheckLocations

		IF EXISTS(SELECT 1 FROM #temptable)
		BEGIN
			RAISERROR('Department exist in transactions',16,1)
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			--Audit Log -- Added By Nivesh 2024-02-19
		IF EXISTS (SELECT 1 FROM [Departments] WHERE [Id] = @Id)
		BEGIN
			EXEC Inventry_AuditTail_WriteToLog 'Departments', @Id, 'INV', 'DEPD', 'D', @LastModUserID,@PropertyID, '', ''
		END
		DELETE [Departments] WHERE [Id] = @Id
	END
		
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	SET @status = -1;
	--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

