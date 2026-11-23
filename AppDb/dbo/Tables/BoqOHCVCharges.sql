CREATE TABLE [dbo].[BoqOHCVCharges] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [ProjectId]     INT             NOT NULL,
    [BoqId]         INT             NOT NULL,
    [SectionId]     INT             NOT NULL,
    [WorkId]        INT             NOT NULL,
    [RateId]        INT             NOT NULL,
    [ItemId]        INT             NOT NULL,
    [OhcpRate]      DECIMAL (18, 2) NOT NULL,
    [OhcpValue]     DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             DEFAULT ((0)) NOT NULL,
    [LastModUserID] INT             DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]   DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    CONSTRAINT [PK_dbo.BoqOHCVCharges] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

