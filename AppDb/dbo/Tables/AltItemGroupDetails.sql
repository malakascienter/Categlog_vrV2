CREATE TABLE [dbo].[AltItemGroupDetails] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [GroupID]       INT            NOT NULL,
    [ItemId]        INT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.AltItemGroupDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

