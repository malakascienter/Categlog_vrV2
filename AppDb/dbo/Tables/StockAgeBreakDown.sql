CREATE TABLE [dbo].[StockAgeBreakDown] (
    [ID]       INT           IDENTITY (1, 1) NOT NULL,
    [TypeName] VARCHAR (MAX) NULL,
    [FromVal]  INT           NULL,
    [ToVal]    INT           NULL,
    [IsActive] BIT           CONSTRAINT [DF_StockAgeBreakDown_IsActive] DEFAULT ((1)) NULL
);


GO

