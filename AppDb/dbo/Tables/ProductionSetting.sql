CREATE TABLE [dbo].[ProductionSetting] (
    [Id]                       INT IDENTITY (1, 1) NOT NULL,
    [DefaultLocationId]        INT NULL,
    [CompanyId]                INT NULL,
    [IsRecipeMaintainLocation] BIT NULL,
    [IsProductionOutQty]       BIT CONSTRAINT [DF_ProductionSetting_IsProductionOutQty] DEFAULT ((0)) NULL
);


GO

