CREATE TABLE [dbo].[SalesPersons] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [SalesPersonCode] NVARCHAR (MAX) NULL,
    [SalesPersonName] NVARCHAR (MAX) NULL,
    [ReferenceNo]     NVARCHAR (MAX) NULL,
    [Remark]          NVARCHAR (MAX) NULL,
    [Address1]        NVARCHAR (MAX) NULL,
    [Address2]        NVARCHAR (MAX) NULL,
    [Address3]        NVARCHAR (MAX) NULL,
    [Email]           NVARCHAR (MAX) NULL,
    [Telephone]       NVARCHAR (MAX) NULL,
    [Mobile]          NVARCHAR (MAX) NULL,
    [IPAddress]       NVARCHAR (MAX) NULL,
    [CreatedUserID]   INT            DEFAULT ((0)) NOT NULL,
    [LastModUserID]   INT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]     DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]     DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [PropertyID]      INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.SalesPersons] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

