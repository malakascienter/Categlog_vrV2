CREATE TABLE [dbo].[SignaturesReportModels] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [TransactionID] INT            NOT NULL,
    [OrderNum]      INT            NOT NULL,
    CONSTRAINT [PK_dbo.SignaturesReportModels] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

