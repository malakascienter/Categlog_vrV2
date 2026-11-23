CREATE TABLE [dbo].[PoApprovalLog] (
    [ID]               INT             IDENTITY (1, 1) NOT NULL,
    [PoHeaderID]       INT             NULL,
    [PoDetailID]       INT             NULL,
    [StockItemID]      INT             NULL,
    [ApprovalLevelID]  INT             NULL,
    [PoQuantity]       DECIMAL (18, 6) NULL,
    [ApprovedQuantity] DECIMAL (18, 6) NULL,
    [ApprovalDate]     DATETIME        NULL,
    [UserID]           INT             NULL,
    [UserName]         NCHAR (20)      NULL
);


GO

