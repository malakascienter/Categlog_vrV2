CREATE TABLE [dbo].[SupplierQuotation] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [ProcurementID]  INT           NULL,
    [SupplierID]     INT           NULL,
    [ItemID]         INT           NULL,
    [QuotationFile]  VARCHAR (255) NOT NULL,
    [Price]          MONEY         NULL,
    [SubmittedDate]  DATETIME      NULL,
    [StatusID]       INT           NULL,
    [ItemName]       VARCHAR (200) NULL,
    [TaxGroupId]     INT           NULL,
    [UserID]         INT           NULL,
    [ApprovedUserID] INT           NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

