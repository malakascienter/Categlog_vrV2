CREATE TABLE [dbo].[RequestTemplateDetails] (
    [TemplateDetailID]  INT             IDENTITY (1, 1) NOT NULL,
    [TemplateHeaderID]  INT             NOT NULL,
    [StockItemHeaderID] INT             NOT NULL,
    [UnitID]            INT             NOT NULL,
    [Qty]               DECIMAL (18, 4) NULL,
    [CreatedUserID]     INT             NOT NULL,
    [ModifiedUserID]    INT             NOT NULL,
    [CreatedDate]       DATETIME        CONSTRAINT [DF_RequestTemplateDetails_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]      DATETIME        CONSTRAINT [DF_RequestTemplateDetails_ModifiedDate] DEFAULT (getdate()) NOT NULL
);


GO

