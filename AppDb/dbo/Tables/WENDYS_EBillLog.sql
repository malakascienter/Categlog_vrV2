CREATE TABLE [dbo].[WENDYS_EBillLog] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [OrderNo]        NVARCHAR (100) NULL,
    [Outlet]         NVARCHAR (200) NULL,
    [ContactNo]      NVARCHAR (30)  NULL,
    [JsonData]       NVARCHAR (MAX) NULL,
    [IsWhatsAppSend] BIT            NULL,
    [MessageId]      NVARCHAR (200) NULL,
    [StatusDetail]   NVARCHAR (MAX) NULL,
    [CreatedDate]    DATETIME       CONSTRAINT [DF_WENDYS_EBillLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [SentDate]       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

