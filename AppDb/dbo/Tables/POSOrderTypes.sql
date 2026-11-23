CREATE TABLE [dbo].[POSOrderTypes] (
    [id]             INT          IDENTITY (1, 1) NOT NULL,
    [Code]           CHAR (1)     NOT NULL,
    [Name]           VARCHAR (50) NOT NULL,
    [PropertyId]     INT          NULL,
    [ChargeHeaderID] INT          DEFAULT ((0)) NOT NULL
);


GO

