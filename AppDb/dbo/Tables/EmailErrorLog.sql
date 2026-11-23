CREATE TABLE [dbo].[EmailErrorLog] (
    [ErrorLogID]   INT             IDENTITY (1, 1) NOT NULL,
    [EmailQueueID] INT             NULL,
    [Email]        NVARCHAR (200)  NULL,
    [ErrorMessage] NVARCHAR (1000) NULL,
    [ErrorDate]    DATETIME        DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
);


GO

