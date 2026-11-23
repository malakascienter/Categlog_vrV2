CREATE TABLE [dbo].[TempMenuPrice] (
    [ItemCode]       CHAR (4)        NOT NULL,
    [PropertyId]     INT             NULL,
    [Price]          DECIMAL (18, 2) NOT NULL,
    [costprice]      DECIMAL (18, 2) NULL,
    [ExecutivePrice] DECIMAL (18, 2) NULL
);


GO

