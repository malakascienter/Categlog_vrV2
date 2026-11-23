CREATE TABLE [dbo].[POS_EBillLog] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [JsonData]       NVARCHAR (MAX) NULL,
    [Outlet]         NVARCHAR (20)  NULL,
    [PropertyID]     INT            NULL,
    [ContactNo]      NVARCHAR (20)  NULL,
    [SysDateTime]    DATETIME       NULL,
    [IsWhatsAppSend] BIT            NULL,
    [IsWhatsappFail] BIT            NULL,
    [FailMessage]    NVARCHAR (MAX) NULL
);


GO

