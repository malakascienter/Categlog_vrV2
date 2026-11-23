CREATE TYPE [dbo].[POS_OutletWiseMenuItemPrice_UDT] AS TABLE (
    [OutLetWiseMenuItemID] INT             NOT NULL,
    [MenuItemCode]         NVARCHAR (10)   NULL,
    [OutletCode]           NVARCHAR (10)   NULL,
    [PriceTypeID]          INT             NULL,
    [Price]                DECIMAL (18, 5) NULL,
    [OldPrice]             DECIMAL (18, 5) NULL,
    [IsActive]             BIT             NULL,
    [CreatedUser]          INT             NULL,
    [ModifiedUser]         INT             NULL);


GO

