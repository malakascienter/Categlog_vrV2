CREATE TABLE [dbo].[PrinterType] (
    [Code]            CHAR (2)     NOT NULL,
    [Description]     VARCHAR (30) CONSTRAINT [DF_PrinterType_Description] DEFAULT ('') NOT NULL,
    [OutletID]        VARCHAR (10) NOT NULL,
    [StockLocation]   VARCHAR (10) CONSTRAINT [DF_PrinterType_StockLocation] DEFAULT ('') NOT NULL,
    [StockLocationID] INT          CONSTRAINT [DF_PrinterType_StockLocationID] DEFAULT ((0)) NOT NULL,
    [DepartmentID]    INT          CONSTRAINT [DF_PrinterType_DepartmentID] DEFAULT ((0)) NOT NULL
);


GO

