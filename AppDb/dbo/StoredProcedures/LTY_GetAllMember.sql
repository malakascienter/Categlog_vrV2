-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get All Members by PropertyId, optional IsActive filter
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllMember]
	@PropertyId INT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;
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
			dbo.FN_LTY_GetMemberPointBalance(PropertyId, PrimaryMobileNo) AS PointBalance
		FROM [dbo].[LTY_Member]
		WHERE PropertyId = @PropertyId
		  AND (@IsActive IS NULL OR IsActive = @IsActive)
		ORDER BY CreatedDate DESC;

END

GO

