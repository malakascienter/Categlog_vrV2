CREATE TABLE [dbo].[POS_DatabaseErrorLog] (
    [ErrorNumber]    VARCHAR (MAX) CONSTRAINT [DF_POS_DatabaseErrorLog_ErrorNumber] DEFAULT ('') NOT NULL,
    [ErrorSeverity]  VARCHAR (MAX) CONSTRAINT [DF_POS_DatabaseErrorLog_ErrorSeverity] DEFAULT ('') NOT NULL,
    [ErrorState]     VARCHAR (MAX) CONSTRAINT [DF_POS_DatabaseErrorLog_ErrorState] DEFAULT ('') NOT NULL,
    [ErrorProcedure] VARCHAR (MAX) CONSTRAINT [DF_POS_DatabaseErrorLog_ErrorProcedure] DEFAULT ('') NOT NULL,
    [ErrorLine]      VARCHAR (MAX) CONSTRAINT [DF_POS_DatabaseErrorLog_ErrorLine] DEFAULT ('') NOT NULL,
    [ErrorMessage]   VARCHAR (MAX) CONSTRAINT [DF_POS_DatabaseErrorLog_ErrorMessage] DEFAULT ('') NOT NULL,
    [SysDate]        DATETIME      CONSTRAINT [DF_POS_DatabaseErrorLog_SysDate] DEFAULT (getdate()) NOT NULL
);


GO

