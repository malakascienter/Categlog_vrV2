CREATE TABLE [dbo].[BoqPriceChangeLogs] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [ProjectId]     INT             NOT NULL,
    [BoqId]         INT             NOT NULL,
    [SectionId]     INT             NOT NULL,
    [WorkId]        INT             NOT NULL,
    [RateId]        INT             NOT NULL,
    [ItemId]        INT             NOT NULL,
    [RevisionPrice] DECIMAL (18, 2) NOT NULL,
    [NewPrice]      DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             DEFAULT ((0)) NOT NULL,
    [LastModUserID] INT             DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]   DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    CONSTRAINT [PK_dbo.BoqPriceChangeLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

