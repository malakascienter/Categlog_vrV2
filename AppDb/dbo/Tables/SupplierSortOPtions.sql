CREATE TABLE [dbo].[SupplierSortOPtions] (
    [ID]       INT          IDENTITY (1, 1) NOT NULL,
    [Code]     CHAR (3)     NULL,
    [Name]     VARCHAR (50) NULL,
    [Seq]      INT          NULL,
    [IsActive] BIT          CONSTRAINT [DF_SupplierSortOPtions_IsActive] DEFAULT ((1)) NULL
);


GO

