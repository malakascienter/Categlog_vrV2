CREATE TABLE [dbo].[InsertStocktransaction_Log] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [HeaderID]       INT            NULL,
    [DocumentNo]     VARCHAR (MAX)  NULL,
    [ErrorProcedure] NVARCHAR (MAX) NULL,
    [Response]       VARCHAR (MAX)  NULL,
    [SysDate]        DATETIME       NULL
);


GO

