

CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedExecutive]

@PropertyId INT,
@MemberID INT
AS
UPDATE	POS_ExecutiveMember SET IsUpload = 1
WHERE	MemberID = @MemberID AND PropertyId = @PropertyId

GO

