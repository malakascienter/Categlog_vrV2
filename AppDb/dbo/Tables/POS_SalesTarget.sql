CREATE TABLE [dbo].[POS_SalesTarget] (
    [Id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [Outlet]      VARCHAR (5)     NOT NULL,
    [MonthNo]     VARCHAR (50)    NOT NULL,
    [YearNo]      VARCHAR (50)    NOT NULL,
    [MonthYear]   VARCHAR (50)    NOT NULL,
    [SalesTarget] DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [PropertyId]  INT             NOT NULL,
    [SysDate]     DATETIME        NOT NULL,
    CONSTRAINT [PK_POS_SalesTarget] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

