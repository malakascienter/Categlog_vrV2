CREATE TABLE [dbo].[Gen_ChargeType_History] (
    [ChargeTypeID]      INT             NOT NULL,
    [SysDate]           DATETIME        CONSTRAINT [DF_Gen_ChargeType_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Name]              VARCHAR (30)    NOT NULL,
    [DisplayName]       VARCHAR (30)    NOT NULL,
    [DefaultPercentage] NUMERIC (18, 4) NOT NULL,
    [IsActive]          BIT             NULL,
    [IsUpload]          BIT             CONSTRAINT [DF_Gen_ChargeType_History_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]        INT             NULL,
    [CreatedUserId]     INT             NULL,
    [CreatedDateTime]   DATETIME        NULL,
    [UpdatedUserId]     INT             NULL,
    [UpdatedDateTime]   DATETIME        NULL,
    [FiscalNo]          INT             DEFAULT ((0)) NOT NULL
);


GO

