-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Delete Member by MemberId and PropertyId. Refused once the member
--              has point transactions, since deleting would orphan their history.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_DeleteMember]
	@MemberId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_Member]
					   WHERE MemberId = @MemberId AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('The member no longer exists.', 16, 1);
		END

		IF EXISTS (SELECT 1 FROM [dbo].[LTY_MemberWisePointTransaction]
				   WHERE MemberId   = @MemberId
					 AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('This member has point transactions and cannot be deleted. Deactivate the member instead.', 16, 1);
		END

		DELETE FROM [dbo].[LTY_Member]
		WHERE MemberId   = @MemberId
		  AND PropertyId = @PropertyId;

		COMMIT TRANSACTION;

		SELECT @MemberId AS MemberId;

	END TRY
	BEGIN CATCH

		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

