CREATE TABLE [dbo].[EmailFailureLog] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [SupplierId]        INT            NOT NULL,
    [PurchaseRequestID] INT            NULL,
    [ErrorMessage]      NVARCHAR (MAX) NOT NULL,
    [ErrorDate]         DATETIME       CONSTRAINT [DF__EmailFail__Error__653C9663] DEFAULT (getdate()) NOT NULL,
    [filePath]          VARCHAR (MAX)  NULL,
    [IsView]            BIT            CONSTRAINT [DF_EmailFailureLog_IsView] DEFAULT ((0)) NULL,
    [isMailSent]        BIT            CONSTRAINT [DF_EmailFailureLog_isMailSent] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__EmailFai__3214EC07454B7F5E] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

