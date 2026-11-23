CREATE TABLE [dbo].[POS_VoucherMode] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Code]       VARCHAR (2)   NULL,
    [Name]       VARCHAR (100) NOT NULL,
    [IsActive]   BIT           NULL,
    [PropertyId] INT           NOT NULL
);


GO

