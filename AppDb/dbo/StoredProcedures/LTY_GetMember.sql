-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get Single Member by MemberId and PropertyId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetMember]
	@MemberId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT
			MemberId,
			MembershipCode,
			PropertyId,
			Salutation,
			FirstName,
			LastName,
			Email,
			PrimaryMobileNo,
			SecondaryMobileNo,
			Address,
			IsActive,
			RegisterOutlet,
			TierId,
			Birthday,
			CreatedBy,
			CreatedDate,
			ModifyBy,
			ModifyDate
		FROM [dbo].[LTY_Member]
		WHERE MemberId   = @MemberId
		  AND PropertyId = @PropertyId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

