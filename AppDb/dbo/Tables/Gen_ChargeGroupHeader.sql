CREATE TABLE [dbo].[Gen_ChargeGroupHeader] (
    [ChargeHeaderID]  INT             IDENTITY (1, 1) NOT NULL,
    [Name]            VARCHAR (30)    CONSTRAINT [DF_Gen_ChargeGroupHeader_Name] DEFAULT ('') NOT NULL,
    [ResNetVal]       NUMERIC (18, 8) CONSTRAINT [DF_Table_1_DefaultPercentage] DEFAULT ((0)) NOT NULL,
    [IsActive]        BIT             NULL,
    [IsUpload]        BIT             CONSTRAINT [DF_Gen_ChargeGroupHeader_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]      INT             NULL,
    [CreatedUserId]   INT             NULL,
    [CreatedDateTime] DATETIME        NULL,
    [UpdatedUserId]   INT             NULL,
    [UpdatedDateTime] DATETIME        NULL,
    [FiscalNo]        INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Gen_ChargeGroupHeader] PRIMARY KEY CLUSTERED ([ChargeHeaderID] ASC)
);


GO

