CREATE TABLE [dbo].[RecipeWiseDocument] (
    [Id]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [RecipeCode]          VARCHAR (500) DEFAULT ('') NOT NULL,
    [DocumentName]        VARCHAR (500) DEFAULT ('') NOT NULL,
    [IsActive]            BIT           DEFAULT ((0)) NOT NULL,
    [SysDate]             DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedUserId]       INT           DEFAULT ((0)) NOT NULL,
    [DocumentDisplayName] VARCHAR (500) DEFAULT ('') NOT NULL,
    [PropertyId]          INT           DEFAULT ((0)) NOT NULL
);


GO

