CREATE procedure [dbo].[SP_InsertProjectWiseSubcontractorsDetails]
(   @Id INT,
	@PWSID int,
	@UnitDesignatorID int,
	@Qty decimal(18, 2),
	@Rate decimal(18, 2),
	@AdavanceAmount decimal(18, 2),
	@RetentionsPeriodInMonths decimal(18, 2),
	@Retentions decimal(18, 2),
	@Total decimal(18, 2),
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@IsValid BIT,
	@CreatedDate datetime,
	@LastModDate datetime
)

as

set nocount on
BEGIN TRY
	BEGIN TRANSACTION
--if exists(select * from ProjectWiseSubcontractorsDetails as PWSD where PWSD.PWSID = @PWSID and )

insert into [ProjectWiseSubcontractorsDetails]
(
	[PWSID],
	[UnitDesignatorID],
	[Qty],
	[Rate],
	[AdavanceAmount],
	[RetentionsPeriodInMonths],
	[Retentions],
	[Total],
	[IPAddress],
	[CreatedUserID],
	[LastModUserID],
	[CreatedDate],
	[LastModDate]
)
values
(
	@PWSID,
	@UnitDesignatorID,
	@Qty,
	@Rate,
	@AdavanceAmount,
	@RetentionsPeriodInMonths,
	@Retentions,
	@Total,
	@IPAddress,
	@CreatedUserID,
	@LastModUserID,
	@CreatedDate,
	@LastModDate
)

select scope_identity()
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
		SELECT
		ERROR_NUMBER() AS ErrorNumber
		,ERROR_SEVERITY() AS ErrorSeverity
		,ERROR_STATE() AS ErrorState
		,ERROR_PROCEDURE() AS ErrorProcedure
		,ERROR_LINE() AS ErrorLine
	,ERROR_MESSAGE() AS ErrorMessage
END CATCH

GO

