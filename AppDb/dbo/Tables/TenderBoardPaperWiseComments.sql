CREATE TABLE [dbo].[TenderBoardPaperWiseComments] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [TBPHeaderID]       INT            NOT NULL,
    [SupplierID]        INT            NOT NULL,
    [StockItemHeaderID] INT            NOT NULL,
    [Comment]           NVARCHAR (MAX) NULL,
    [ActionID]          INT            NOT NULL,
    [CreatedUserID]     INT            NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [TypeId]            INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.TenderBoardPaperWiseComments] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

