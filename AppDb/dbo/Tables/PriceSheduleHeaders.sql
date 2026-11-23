CREATE TABLE [dbo].[PriceSheduleHeaders] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]    INT            NOT NULL,
    [DocNO]         NVARCHAR (MAX) NULL,
    [AffectedDate]  DATETIME       NOT NULL,
    [DocStatus]     NVARCHAR (MAX) NULL,
    [Isapproved]    BIT            NOT NULL,
    [ReqType]       NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [LocationID]    INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.PriceSheduleHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

