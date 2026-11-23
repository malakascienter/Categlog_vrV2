CREATE TABLE [dbo].[POS_MainMenuPriceTypes] (
    [PriceTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [PriceTypeName] NVARCHAR (50) NOT NULL,
    [IsActive]      BIT           NULL,
    [CreatedUser]   INT           NULL,
    [CreatedDate]   DATETIME      NULL,
    [ModifiedUser]  INT           NULL,
    [ModifiedDate]  DATETIME      NULL,
    CONSTRAINT [PK_POS_MainMenuPriceTypes] PRIMARY KEY CLUSTERED ([PriceTypeID] ASC)
);


GO

