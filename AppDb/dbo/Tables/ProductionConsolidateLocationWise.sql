CREATE TABLE [dbo].[ProductionConsolidateLocationWise] (
    [ID]                            INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]                    INT             NULL,
    [ProductionConsolidateHeaderID] INT             NULL,
    [CommiRequestHeaderID]          INT             NULL,
    [ProductionLocationID]          INT             NULL,
    [RequestedLocationID]           INT             NULL,
    [StockItemID]                   INT             NULL,
    [RequestedQTY]                  DECIMAL (18, 6) NULL,
    [UnitID]                        INT             NULL,
    [sysDateTime]                   DATETIME        NULL,
    [UserID]                        INT             NULL,
    [MasterUnitID]                  INT             NULL,
    [ConvertedQuantity]             DECIMAL (18, 6) NULL
);


GO

