CREATE TABLE [dbo].[UnitConversions] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [LocationId]    INT            NOT NULL,
    [FromUnitID]    INT            NOT NULL,
    [ToUnitID]      INT            NOT NULL,
    [Value]         REAL           NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [FromUnitName]  NVARCHAR (MAX) NULL,
    [ToUnitName]    NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [CompanyId]     INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.UnitConversions] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

