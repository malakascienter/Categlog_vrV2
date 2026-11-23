CREATE TABLE [dbo].[MRNRegistryDetails] (
    [ID]            INT             IDENTITY (1, 1) NOT NULL,
    [LocationId]    INT             NOT NULL,
    [MRNId]         INT             NOT NULL,
    [POId]          INT             NOT NULL,
    [GRNId]         INT             NOT NULL,
    [ItemId]        INT             NOT NULL,
    [Quantity]      DECIMAL (18, 2) NOT NULL,
    [Balance]       DECIMAL (18, 2) NOT NULL,
    [Price]         DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.MRNRegistryDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

