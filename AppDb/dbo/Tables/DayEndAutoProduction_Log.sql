CREATE TABLE [dbo].[DayEndAutoProduction_Log] (
    [ID]                    INT        IDENTITY (1, 1) NOT NULL,
    [ProductionOutHeaderID] INT        NULL,
    [OutletCode]            NCHAR (10) NULL,
    [Txndate]               DATE       NULL,
    [LocationID]            INT        NULL
);


GO

