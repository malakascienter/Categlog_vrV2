

--select * from Companies
--select * from UserMasters
--select * from Departments

--Verify_Location 1,'Venora International' , 3, 'asanga' , 1 , 'Tendering'

CREATE PROCEDURE [dbo].[Verify_Location] 
	@CompanyID int,
	@companyName VARCHAR(max),
	@UserID int,
	@username  VARCHAR(max),
	@DepartmentID int,
	@departmentName VARCHAR(max)

AS

declare @companyOK bit
declare @userOK bit
declare @departmentOK bit
declare @verification bit
declare @message varchar (100)

BEGIN
	set @message =''

	--check company name and id
	IF EXISTS (SELECT * FROM Companies
			  WHERE CompanyID = @CompanyID AND Name = @companyName)
	BEGIN
		set @companyOK = 1 
	END
	ELSE
	BEGIN
		set @message += 'Company'
		set @companyOK = 0
	END
	
	--Check User id and User name
	IF EXISTS ( SELECT * FROM UserMasters
				WHERE Id=@UserID AND UserName=@username)
	BEGIN
		SET @userOK =1
	END
	ELSE
	BEGIN
		set @message += ', Users'
		SET @userOK =0
	END
	
	--Check User id and User name
	IF EXISTS ( SELECT * FROM Departments
				WHERE Id=@DepartmentID AND Name=@departmentName)
	BEGIN
		SET @departmentOK =1
	END
	ELSE
	BEGIN
		set @message += ', Department'
		SET @departmentOK =0
	END

	
		IF  @companyOK =1 AND @userOK=1 AND @departmentOK=1
		BEGIN
			print 'Case 1'
			set @message = 'Varify Pass '
			set @verification =1
		END
		ELSE
		BEGIN
			print 'Case 2'
			set @message = 'Cannot verify the values of ' + @message  
			set @verification = 0
		END

		
		select @message 'Message' , @verification 'IsVerify'

END

GO

