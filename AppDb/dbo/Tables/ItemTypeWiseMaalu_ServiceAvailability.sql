CREATE TABLE [dbo].[ItemTypeWiseMaalu_ServiceAvailability] (
    [Id]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [ItemTypeId] INT          NOT NULL,
    [DayName]    VARCHAR (50) NULL
);


GO

CREATE NONCLUSTERED INDEX [IX_ItemTypeWiseMaalu_ServiceAvailability_ItemTypeId]
    ON [dbo].[ItemTypeWiseMaalu_ServiceAvailability]([ItemTypeId] ASC);


GO

