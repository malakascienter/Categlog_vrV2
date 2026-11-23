-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 11 MAY 2023
-- Description:	Loading departments based on UserID
-- [dbo].[SP_UserWiseDepartments] 4168,-999
-- =============================================
create PROCEDURE [dbo].[SP_UserWiseDepartments]
	@userID INT,
	@comanyid INT

AS
BEGIN

	  SELECT D.Id AS 'id', D.Name AS 'text'
	  FROM Departments D
      INNER JOIN UserWiseDepartments UD on D.Id = UD.deptid
      WHERE UD.userId = @userID AND D.PropertyID= CASE WHEN @comanyid = -999 THEN  D.PropertyID ELSE @comanyid END
	  AND D.IsActive=1
	  ORDER BY D.Name

	
	
END

GO

