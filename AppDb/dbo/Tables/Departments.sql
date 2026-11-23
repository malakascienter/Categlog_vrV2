CREATE TABLE [dbo].[Departments] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [LocationID]      INT            NOT NULL,
    [Code]            NVARCHAR (MAX) NULL,
    [Name]            NVARCHAR (MAX) NULL,
    [IsApplyForFO]    BIT            NOT NULL,
    [IsApplyForInv]   BIT            NOT NULL,
    [IsApplyForBan]   BIT            NOT NULL,
    [IsActive]        BIT            NOT NULL,
    [IPAddress]       NVARCHAR (MAX) NULL,
    [CreatedUserID]   INT            NOT NULL,
    [LastModUserID]   INT            NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [LastModDate]     DATETIME       NOT NULL,
    [PropertyID]      INT            DEFAULT ((0)) NOT NULL,
    [IsPaxCount]      BIT            CONSTRAINT [DF_Departments_IsPaxCount] DEFAULT ((0)) NOT NULL,
    [LocationCode]    NVARCHAR (MAX) NULL,
    [CustomerBSPCode] VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.Departments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

