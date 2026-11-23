



CREATE PROCEDURE [dbo].[Sync_spGetMembers]

AS
	--SYNONYM FROM "MembershipModule" DATABASE
	--CREATE SYNONYM [dbo].[Members] FOR [MembershipModule].[dbo].[Members]

	SELECT	M.Id AS Memberid , I.MembershipNo, NameWithIntials, ThumbNo AS  ThumbID, C.ContactNo, E.EmailAddress, M.IsActive
	FROM	Members M INNER JOIN MemberWiseIdentifications I ON M.Id = I.MemberId
			INNER JOIN MemberWiseContactNo C ON M.Id = C.MemberId
			INNER JOIN MemberWiseEmailAddresses E ON M.Id = E.MemberId
	WHERE	M.IsUpload = 0

GO

