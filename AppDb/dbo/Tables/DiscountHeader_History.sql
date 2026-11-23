CREATE TABLE [dbo].[DiscountHeader_History] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Code]               CHAR (2)        NOT NULL,
    [Description]        VARCHAR (30)    NOT NULL,
    [TimeFrom]           TIME (7)        NULL,
    [TimeTo]             TIME (7)        NULL,
    [DateFrom]           DATETIME        NULL,
    [DateTo]             DATETIME        NULL,
    [Percentage]         NUMERIC (18, 2) NOT NULL,
    [IsAutoApply]        BIT             NOT NULL,
    [IsAuthorization]    BIT             NOT NULL,
    [IsDay]              BIT             NOT NULL,
    [SysDate]            DATETIME        NOT NULL,
    [ValidationMode]     VARCHAR (5)     NOT NULL,
    [DiscountType]       VARCHAR (5)     NULL,
    [IsNeedRemark]       BIT             NOT NULL,
    [IsValidatePayType]  BIT             NOT NULL,
    [DiscountValue]      NUMERIC (18, 2) NOT NULL,
    [IsActive]           BIT             NULL,
    [OutletListJson]     NVARCHAR (MAX)  NULL,
    [MenuItemJson]       NVARCHAR (MAX)  NULL,
    [DaysJson]           NVARCHAR (MAX)  NULL,
    [IsItemWiseDiscount] BIT             NULL,
    [IsPercentage]       BIT             NULL,
    [IsUpload]           BIT             NULL,
    [PropertyId]         INT             NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [UpdatedUserId]      INT             NULL,
    [UpdatedDateTime]    DATETIME        NULL,
    [ValidationModesId]  INT             DEFAULT ((0)) NOT NULL
);


GO

