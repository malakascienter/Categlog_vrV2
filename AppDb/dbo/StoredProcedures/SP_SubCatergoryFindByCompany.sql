
CREATE PROCEDURE [dbo].[SP_SubCatergoryFindByCompany] 
	@companyid INT 
AS
BEGIN
    BEGIN TRANSACTION;
	--set @companyid = 0; --for network error testing purposes 
    BEGIN TRY
	IF(@CompanyId = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured :Company ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

	--SELECT * FROM dbo.SubCategories WHERE CompanyId = @companyid
	SELECT * FROM dbo.SubCategories where  IsActive = 1

        COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
	
END;

GO

