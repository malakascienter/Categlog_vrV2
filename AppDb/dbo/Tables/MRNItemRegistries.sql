CREATE TABLE [dbo].[MRNItemRegistries] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]            INT             NOT NULL,
    [BOQId]             INT             NOT NULL,
    [DepId]             INT             NOT NULL,
    [BOQQuantity]       DECIMAL (18, 2) NOT NULL,
    [RequestQuantity]   DECIMAL (18, 2) NOT NULL,
    [IssueQuantity]     DECIMAL (18, 2) NOT NULL,
    [BalanceQuantity]   DECIMAL (18, 2) NOT NULL,
    [SuspendedQuantity] DECIMAL (18, 2) NOT NULL,
    [IPAddress]         NVARCHAR (MAX)  NULL,
    [CreatedUserID]     INT             NOT NULL,
    [LastModUserID]     INT             NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [LastModDate]       DATETIME        NOT NULL,
    [ProjectID]         INT             DEFAULT ((0)) NOT NULL,
    [UnitID]            INT             DEFAULT ((0)) NOT NULL,
    [Source]            VARCHAR (50)    NULL,
    CONSTRAINT [PK_dbo.MRNItemRegistries] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

