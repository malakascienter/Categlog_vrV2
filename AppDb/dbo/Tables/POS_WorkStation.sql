CREATE TABLE [dbo].[POS_WorkStation] (
    [ID]            TINYINT       NOT NULL,
    [ComputerName]  VARCHAR (100) NOT NULL,
    [Counter]       VARCHAR (5)   NOT NULL,
    [LocationID]    INT           NOT NULL,
    [UserID]        INT           NOT NULL,
    [InvoicePrefix] VARCHAR (3)   NOT NULL,
    [InvoiceNo]     BIGINT        NOT NULL,
    [PropertyID]    INT           NULL
);


GO

