CREATE TABLE [dbo].[InvoiceDetails] (
    [ID]                      INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceHeaderID]         INT             NOT NULL,
    [ItemID]                  INT             NOT NULL,
    [QTY]                     DECIMAL (18, 2) NOT NULL,
    [UnitID]                  INT             NOT NULL,
    [UnitPrice]               DECIMAL (18, 2) NOT NULL,
    [DelievryQTY]             DECIMAL (18, 2) NOT NULL,
    [ReturnQty]               DECIMAL (18, 2) NOT NULL,
    [AveragePrice]            DECIMAL (18, 2) NOT NULL,
    [CostPrice]               DECIMAL (18, 2) NOT NULL,
    [TaxGroupID]              INT             NOT NULL,
    [TaxValue]                DECIMAL (18, 2) NOT NULL,
    [SerialNo]                NVARCHAR (MAX)  NULL,
    [ItemDiscountValue]       DECIMAL (18, 2) NOT NULL,
    [ItemDiscountType]        INT             NOT NULL,
    [IPAddress]               NVARCHAR (MAX)  NULL,
    [CreatedUserID]           INT             NOT NULL,
    [LastModUserID]           INT             NOT NULL,
    [CreatedDate]             DATETIME        NOT NULL,
    [LastModDate]             DATETIME        NOT NULL,
    [ItemDiscountPercentage]  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [WarrentyPeriod]          DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsPercentageForDiscount] BIT             DEFAULT ((0)) NOT NULL,
    [TaxCostPrice]            DECIMAL (18, 2) NULL,
    [TaxForSellPrice]         DECIMAL (18, 2) NULL,
    [PrintSequence]           DECIMAL (18, 2) NULL,
    [TxnType]                 CHAR (1)        CONSTRAINT [DF_InvoiceDetails_TxnType] DEFAULT ('I') NOT NULL,
    CONSTRAINT [PK_dbo.InvoiceDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

