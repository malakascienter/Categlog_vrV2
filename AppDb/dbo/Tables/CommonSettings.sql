CREATE TABLE [dbo].[CommonSettings] (
    [Id]                             INT IDENTITY (1, 1) NOT NULL,
    [NextSupplierNumber]             INT NOT NULL,
    [ItemTempNo]                     INT DEFAULT ((15000)) NOT NULL,
    [QuotationManageByHOAttributeId] INT NULL,
    [MenuType]                       INT CONSTRAINT [DF_CommonSettings_MenuType] DEFAULT ((1)) NULL,
    [IsPoType]                       BIT NOT NULL,
    [CheckForDefaultSupplier]        BIT NOT NULL
);


GO

