CREATE PROCEDURE[dbo].[SPP_Update_Work]
 --DECLARE PARAMETERS
@Id INT,
@Awarded BIT,
@BOQID INT,
@CreatedDate Datetime,
@CreatedUserID INT,
@DepartmentID INT,
@Description nvarchar(max),
@IPAddress nvarchar(max),
@LastModDate datetime,
@LastModUserID INT,
@MainWorkID INT,
@Quantity decimal,
@Rate decimal,
@SeqNo INT,
@WorkHeaderStatus BIT,
@WorkID INT,
@UnitID INT,
@SundryAmount INT,
@status[int] OUTPUT
	


AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @BOQMAINID INT



	
	UPDATE BOQSubWorkAllocations
	SET Description=@Description,Quantity=@Quantity,DepartmentID=@DepartmentID, UnitID=@UnitID, SundryAmount=@SundryAmount
    WHERE BOQSubWorkAllocations.Id=@Id and BOQID=@BOQID

		SET @statusIN = 1;

	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	SET @status = -1;
		SELECT
		ERROR_NUMBER() AS ErrorNumber
		,ERROR_SEVERITY() AS ErrorSeverity
		,ERROR_STATE() AS ErrorState
		,ERROR_PROCEDURE() AS ErrorProcedure
		,ERROR_LINE() AS ErrorLine
	,ERROR_MESSAGE() AS ErrorMessage
END CATCH
END--SP ENDS

GO

