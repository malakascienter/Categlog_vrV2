

--exec [dbo].[SelectRequestNotes] 20986
CREATE  Procedure [dbo].[SelectRequestNotes] (@HeaderID int)
AS
BEGIN

----------------------------------------------------------------------------------
BEGIN TRY
----added---2/6/21---
DECLARE @CompanyId INT, @IsCentralLogin BIT
SELECT @CompanyId = PropertyID FROM RequestHeaders WHERE Id = @HeaderID --AND RequestType = 'rp' commented by Nivesh 2023-10-05
SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @CompanyId

IF(@IsCentralLogin = 1)
BEGIN

   SELECT RN.*,UM.UserName 
   FROM RequestNotes RN
   INNER JOIN [dbo].[CentralUsers] UM ON UM.Id = RN.UserId
   WHERE HeaderID = @HeaderID
   order by Id
END
------------------------------------------------
ELSe
BEGIN

   SELECT RN.*,UM.UserName  FROM RequestNotes RN
   INNER JOIN UserMasters UM ON UM.Id = RN.UserId
   WHERE HeaderID = @HeaderID
   order by Id
END

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

----------------------------------------------------------------------------------


END

GO

