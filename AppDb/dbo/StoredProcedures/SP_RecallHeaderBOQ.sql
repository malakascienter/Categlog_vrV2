
--[dbo].[SP_RecallHeaderBOQ] 0
CREATE PROCEDURE [dbo].[SP_RecallHeaderBOQ]
	@headerID int
AS
BEGIN
	

	BEGIN TRY 
	-----------------------------------------------------Begin Try-------------------------------------------------------------
	SELECT L.Name AS LocationName, D.Name AS DepartmentName, '' AS TransferLocationName, RH.DocumentNo, RH.CreatedDate, RH.Id ,'BA' AS RequestType ,
			'BA Number'
			 AS DocumentType
	FROM dbo.BOQAmendmentHeader AS RH
	INNER  JOIN dbo.Locations AS L ON RH.LocationID = L.Id
	INNER JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	INNER JOIN dbo.UserMasters AS U ON RH.CreatedUserId = U.Id
	--INNER JOIN RequestHeaders RH ON RH.Id=RD.RequestHeaderID
	INNER JOIN TransactionTypes TT ON TT.Code ='BA'
	WHERE RH.Id = @headerID
	----------------------------------------------------------End Try--------------------------------------------------------
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
END
    

--select * from [dbo].[BOQAmendmentHeader]

GO

