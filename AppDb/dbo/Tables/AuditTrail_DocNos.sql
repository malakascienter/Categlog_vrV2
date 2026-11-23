CREATE TABLE [dbo].[AuditTrail_DocNos] (
    [Code]   NVARCHAR (5) NOT NULL,
    [Prefix] NVARCHAR (1) NOT NULL,
    [NextNo] BIGINT       NOT NULL,
    [Length] INT          NOT NULL
);


GO

