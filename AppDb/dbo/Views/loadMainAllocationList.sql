
CREATE VIEW dbo.loadMainAllocationList
AS
SELECT        Id, BOQID, Description
FROM            dbo.BOQMainWorkAllocations
WHERE        (BOQID = 1)

GO

