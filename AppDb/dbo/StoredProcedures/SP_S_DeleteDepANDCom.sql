
CREATE PROCEDURE SP_S_DeleteDepANDCom @ID INT,@Action INT
AS

BEGIN

IF @Action=1
BEGIN
	DELETE FROM dbo.UserWiseCompanies WHERE id=@Id

END
ELSE
BEGIN
	DELETE FROM dbo.UserWiseDepartments WHERE id=@Id
END

END

GO

