CREATE TABLE [dbo].[Gen_ChargeGroupHeader_History] (
    [ChargeHeaderID]  INT             NOT NULL,
    [Name]            VARCHAR (30)    NOT NULL,
    [ResNetVal]       NUMERIC (18, 4) NOT NULL,
    [IsActive]        BIT             NULL,
    [SysDate]         DATETIME        CONSTRAINT [DF_Gen_ChargeGroupHeader_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsUpload]        BIT             CONSTRAINT [DF_Gen_ChargeGroupHeader_History_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]      INT             NULL,
    [CreatedUserId]   INT             NULL,
    [CreatedDateTime] DATETIME        NULL,
    [UpdatedUserId]   INT             NULL,
    [UpdatedDateTime] DATETIME        NULL,
    [FiscalNo]        INT             DEFAULT ((0)) NOT NULL
);


GO

