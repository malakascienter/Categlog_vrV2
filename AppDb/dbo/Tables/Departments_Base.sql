CREATE TABLE [dbo].[Departments_Base] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [LocationID]    INT            NOT NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [IsApplyForFO]  BIT            NOT NULL,
    [IsApplyForInv] BIT            NOT NULL,
    [IsApplyForBan] BIT            NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [PropertyID]    INT            NOT NULL
);


GO

