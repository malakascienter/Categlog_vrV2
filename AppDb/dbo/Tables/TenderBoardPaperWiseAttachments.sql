CREATE TABLE [dbo].[TenderBoardPaperWiseAttachments] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [TBPHeaderID]   INT            NOT NULL,
    [SupplierID]    INT            NOT NULL,
    [FileName]      NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.TenderBoardPaperWiseAttachments] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

