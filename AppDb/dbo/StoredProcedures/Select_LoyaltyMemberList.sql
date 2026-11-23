-- =============================================
-- Author:		Chiraj
-- Create date: 2020-06-4
-- Description:	Discounts_M_Select
-- =============================================
CREATE PROCEDURE [dbo].[Select_LoyaltyMemberList]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT M.Id AS MemberId,
		   M.MembershipNo AS MemberCode,
		   M.FirstName AS MemberName
	FROM LoyaltyCustomer..Members M 
		

END

GO

