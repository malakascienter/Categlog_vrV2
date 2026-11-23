CREATE TABLE [dbo].[QuotationRequestDetail] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [QuotationRequestId]  INT           NULL,
    [SupplierId]          INT           NULL,
    [SupplierName]        VARCHAR (50)  NULL,
    [SendMail]            BIT           CONSTRAINT [DF_QuotationRequestDetail_SendMail] DEFAULT ((0)) NOT NULL,
    [IsQuotationUploaded] BIT           CONSTRAINT [DF_QuotationRequestDetail_IsQuotationUploaded] DEFAULT ((0)) NULL,
    [QuotationFilePath]   VARCHAR (MAX) NULL,
    [MailStatus]          CHAR (1)      CONSTRAINT [DF_QuotationRequestDetail_MailStatus] DEFAULT ('N') NOT NULL
);


GO

