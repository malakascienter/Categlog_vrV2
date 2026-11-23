CREATE TABLE [dbo].[LogTypes] (
    [ID]   INT            IDENTITY (1, 1) NOT NULL,
    [Type] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.LogTypes] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

