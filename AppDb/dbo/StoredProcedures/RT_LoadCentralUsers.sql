-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-06
-- Description:	Loading Users from CentralUsers

-- RT_LoadCentralUsers 1
-- =============================================
CREATE PROCEDURE [dbo].[RT_LoadCentralUsers]
	@PropertyID INT
AS
BEGIN
SET NOCOUNT ON;

-------------------------------------------------------------------------------------------
BEGIN TRY 
	SELECT CU.Id, UG.Id GroupId,UG.UserGroupName, CU.UserName, CU.FullName, CU.EmpNumber,US.IsPOSUser,US.AccessCard
	FROM  CentralUsers CU
	LEFT JOIN UserMasters US ON CU.ID = US.Id
	LEFT JOIN UserGroups UG ON US.UserGroupID= UG.Id
	WHERE CU.IsActive=1
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
-------------------------------------------------------------------------------------------
END

GO

