CREATE TABLE [dbo].[WaiterWiseOutlets_History] (
    [Id]         INT         IDENTITY (1, 1) NOT NULL,
    [SysDate]    DATETIME    CONSTRAINT [DF_WaiterWiseOutlets_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [WaiterCode] VARCHAR (8) NOT NULL,
    [OutletCode] VARCHAR (3) NOT NULL
);


GO

