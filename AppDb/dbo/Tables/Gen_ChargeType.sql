CREATE TABLE [dbo].[Gen_ChargeType] (
    [ChargeTypeID]      INT             IDENTITY (1, 1) NOT NULL,
    [Name]              VARCHAR (30)    CONSTRAINT [DF_Gen_ChargeType_Name] DEFAULT ('') NOT NULL,
    [DisplayName]       VARCHAR (30)    CONSTRAINT [DF_Table_1_Name1] DEFAULT ('') NOT NULL,
    [DefaultPercentage] NUMERIC (18, 4) CONSTRAINT [DF_Gen_ChargeType_DefaultPercentage] DEFAULT ((0)) NOT NULL,
    [IsActive]          BIT             NULL,
    [IsUpload]          BIT             CONSTRAINT [DF_Gen_ChargeType_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]        INT             NULL,
    [CreatedUserId]     INT             NULL,
    [CreatedDateTime]   DATETIME        NULL,
    [UpdatedUserId]     INT             NULL,
    [UpdatedDateTime]   DATETIME        NULL,
    [FiscalNo]          INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Gen_ChargeType] PRIMARY KEY CLUSTERED ([ChargeTypeID] ASC)
);


GO

