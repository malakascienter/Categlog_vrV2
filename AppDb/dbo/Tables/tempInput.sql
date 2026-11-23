CREATE TABLE [dbo].[tempInput] (
    [id]             INT      IDENTITY (1, 1) NOT NULL,
    [xmldata]        XML      NULL,
    [LogDate]        DATETIME CONSTRAINT [DF_tempInput_LogDate] DEFAULT (getdate()) NOT NULL,
    [POHeaderID]     INT      NULL,
    [IsQuotation]    BIT      CONSTRAINT [DF_tempInput_IsQuotation] DEFAULT ((0)) NOT NULL,
    [IsInvoiceBased] BIT      CONSTRAINT [DF_tempInput_IsInvoiceBased] DEFAULT ((0)) NOT NULL
);


GO

CREATE NONCLUSTERED INDEX [tempInput_id]
    ON [dbo].[tempInput]([id] ASC);


GO

