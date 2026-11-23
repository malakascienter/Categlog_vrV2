CREATE PROCEDURE [dbo].[SPP_loadMainAllocationList]
	@value int
AS
BEGIN
	SELECT        B.Id, B.BOQID, B.Description
	FROM           BOQMainWorkAllocations as B
	WHERE        B.BOQID = @value
END

GO

