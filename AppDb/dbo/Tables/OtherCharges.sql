CREATE TABLE [dbo].[OtherCharges] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [CompanyID]     INT            NOT NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [AccountID]     BIGINT         NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.OtherCharges] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

