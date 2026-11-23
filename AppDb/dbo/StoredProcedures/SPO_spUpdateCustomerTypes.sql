
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE PROCEDURE [dbo].[SPO_spUpdateCustomerTypes]
	@CustomerTypeJson VARCHAR(MAX)
AS
BEGIN
BEGIN  TRY
BEGIN TRANSACTION

	SET NOCOUNT ON;

	CREATE TABLE #CustomerType
	(
		ID INT,
		CustomerTypeName NVARCHAR(100),
		IsActive BIT,
		isEnableCompanyDetails BIT,
		isEnableEmployeeDetails BIT,
		isEnableCreditDetails BIT,
		PropertyId INT,
		IsCustomerApprove BIT
	);




	INSERT INTO #CustomerType (ID, CustomerTypeName,IsActive,PropertyId,isEnableCompanyDetails,isEnableEmployeeDetails,isEnableCreditDetails,IsCustomerApprove)
	SELECT ID, CustomerTypeName,IsActive,PropertyId,isEnableCompanyDetails,isEnableEmployeeDetails,isEnableCreditDetails,IsCustomerApprove
	FROM OPENJSON(@CustomerTypeJson)
	WITH (
		ID INT '$.ID',
		CustomerTypeName NVARCHAR(100) '$.CustomerTypeName',
		IsActive BIT '$.isActive',
		isEnableCompanyDetails BIT '$.isEnableCompanyDetails',
		isEnableEmployeeDetails BIT '$.isEnableEmployeeDetails',
		isEnableCreditDetails BIT '$.isEnableCreditDetails',
		PropertyId INT '$.PropertyId',
		IsCustomerApprove BIT '$.IsCustomerApprove'
	);


	DECLARE @Id int 

	select @Id = ID from #CustomerType


	IF( @Id > 0 )
	BEGIN

		UPDATE O
		SET O.CustomerTypeName = T.CustomerTypeName,
			O.IsActive = T.IsActive,
			O.isEnableCompanyDetails = T.isEnableCompanyDetails,
			O.isEnableEmployeeDetails = T.isEnableEmployeeDetails,
			O.isEnableCreditDetails = T.isEnableCreditDetails,
			O.IsCustomerApprove = T.IsCustomerApprove
		FROM #CustomerType T INNER JOIN SPO_CustomerType O ON T.ID = O.ID


	END
	ELSE
	BEGIN

 		INSERT INTO [dbo].[SPO_CustomerType]
			   ([CustomerTypeName]
			   ,[IsActive]
			   ,[isEnableCompanyDetails]
			   ,[isEnableEmployeeDetails]
			   ,[isEnableCreditDetails]
			   ,[PropertyId]
			   ,[CreatedUserId]
			   ,[CreatedDatetime]
			   ,[LastEditedUserId]
			   ,[LastEditedDateTime]
			   ,[IsCustomerApprove]
			   )
		SELECT CustomerTypeName,
		       IsActive,
			   isEnableCompanyDetails,
			   isEnableEmployeeDetails,
			   isEnableCreditDetails,
			   PropertyId,
			   0,
			   GETDATE(),
			   0,
			   GETDATE(),
			   IsCustomerApprove
		FROM #CustomerType

	END





	DROP TABLE #CustomerType


COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH
    
END

GO

