CREATE TABLE [dbo].[sys_suppwise] (
    [SuppCode]      CHAR (5)    NOT NULL,
    [location]      CHAR (3)    NOT NULL,
    [ItemCode]      CHAR (16)   NOT NULL,
    [Unit]          VARCHAR (3) NOT NULL,
    [Price]         MONEY       NOT NULL,
    [LeadTime]      INT         NOT NULL,
    [MinimumOrdQty] MONEY       NOT NULL
);


GO

