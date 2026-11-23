CREATE TABLE [dbo].[AuditTrail_UserWisePageVisitCount] (
    [UserId]     INT NOT NULL,
    [PageId]     INT NOT NULL,
    [NoOfVisits] INT CONSTRAINT [DF_AuditTrail_UserWisePageVisitCount_NoOfVisits] DEFAULT ((0)) NOT NULL,
    [PropertyId] INT NULL
);


GO

