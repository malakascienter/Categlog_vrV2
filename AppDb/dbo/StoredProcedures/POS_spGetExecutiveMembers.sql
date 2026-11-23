
CREATE PROCEDURE [dbo].[POS_spGetExecutiveMembers]

AS 
SET NOCOUNT ON

SELECT	MemberID AS Code, MemberName AS Name, EPFNo AS EPF
FROM	POS_ExecutiveMember
WHERE	Active = 1

GO

