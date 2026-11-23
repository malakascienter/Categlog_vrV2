
CREATE PROCEDURE [dbo].[POS_spGetExecutiveMembersPropertyWise]
@PropertyId INT
AS 
SET NOCOUNT ON

SELECT	MemberID AS Code, MemberName AS Name, EPFNo AS EPF
FROM	POS_ExecutiveMember
WHERE	Active = 1 AND PropertyId = @PropertyId

GO

