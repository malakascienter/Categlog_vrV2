-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get Single Member by Mobile and PropertyId
-- =============================================
-- EXEC [dbo].[LTY_GetMemberByMobileNo] @MobileNo = '0702375050', @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_GetMemberByMobileNo]
	@MobileNo NVARCHAR(20),
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
			ModifyDate,
			dbo.FN_LTY_GetMemberPointBalance(@PropertyId, @MobileNo)       AS PointBalance,
			dbo.FN_LTY_GetMemberMonthlyVisitCount(@PropertyId, @MobileNo) AS MonthlyVisitCount,
			dbo.FN_LTY_GetMemberTotalVisitCount(@PropertyId, @MobileNo)   AS TotalAllVisitCount
		FROM [dbo].[LTY_Member]
		WHERE PrimaryMobileNo = @MobileNo
		  AND PropertyId      = @PropertyId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

