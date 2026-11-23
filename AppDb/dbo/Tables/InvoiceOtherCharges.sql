CREATE TABLE [dbo].[InvoiceOtherCharges] (
    [ID]              INT             IDENTITY (1, 1) NOT NULL,
    [OtherChargID]    INT             NOT NULL,
    [InvoiceHeaderID] INT             NOT NULL,
    [Amount]          DECIMAL (18, 2) NOT NULL,
    [Remarks]         NVARCHAR (MAX)  NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.InvoiceOtherCharges] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

