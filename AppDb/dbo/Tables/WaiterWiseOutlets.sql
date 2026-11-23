CREATE TABLE [dbo].[WaiterWiseOutlets] (
    [Id]         INT         IDENTITY (1, 1) NOT NULL,
    [WaiterCode] VARCHAR (8) NOT NULL,
    [OutletCode] VARCHAR (3) NOT NULL,
    [SysDate]    DATETIME    NULL
);


GO

