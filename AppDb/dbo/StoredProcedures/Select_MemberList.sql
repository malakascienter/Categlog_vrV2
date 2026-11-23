-- =============================================
-- Author:		Chiraj
-- Create date: 2020-06-4
-- Description:	Discounts_M_Select
-- =============================================
CREATE PROCEDURE [dbo].[Select_MemberList]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT M.Id AS MemberId,
		   MI.MembershipNo AS MemberCode,
		   M.FirstName + ' ' + M.LastName AS MemberName
	FROM MembershipModule..Members M 
	INNER JOIN MembershipModule..MemberWiseIdentifications MI	ON M.Id	= MI.MemberId
		

END

GO

