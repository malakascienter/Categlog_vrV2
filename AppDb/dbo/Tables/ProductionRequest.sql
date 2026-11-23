CREATE TABLE [dbo].[ProductionRequest] (
    [ID]          INT             IDENTITY (1, 1) NOT NULL,
    [StockItemID] INT             NULL,
    [OrderQty]    DECIMAL (18, 6) NULL,
    [LocationID]  INT             NULL,
    [PropertyID]  INT             NULL,
    [IsCompleted] BIT             CONSTRAINT [DF_ProductionRequest_IsCompleted] DEFAULT ((0)) NULL,
    [SysDate]     DATETIME        CONSTRAINT [DF_ProductionRequest_SysDate] DEFAULT (getdate()) NULL
);


GO

