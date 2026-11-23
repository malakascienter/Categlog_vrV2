CREATE TYPE [dbo].[POS_MainMenuPriceTypes_UDT] AS TABLE (
    [PriceTypeID]   INT           NOT NULL,
    [PriceTypeName] NVARCHAR (50) NOT NULL,
    [IsActive]      BIT           NULL);


GO

