CREATE TABLE [dbo].[SPO_OrderType] (
    [ID]                      INT             IDENTITY (1, 1) NOT NULL,
    [OrderTypeName]           VARCHAR (MAX)   CONSTRAINT [DF_SPO_OrderType_OrderTypeName] DEFAULT ('') NOT NULL,
    [PropertyId]              INT             CONSTRAINT [DF__SPO_Order__Prope__5F2495B1] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]           INT             CONSTRAINT [DF__SPO_Order__Creat__6018B9EA] DEFAULT ((0)) NOT NULL,
    [CreatedDateTime]         DATETIME        CONSTRAINT [DF__SPO_Order__Creat__610CDE23] DEFAULT (getdate()) NOT NULL,
    [EditedUserId]            INT             CONSTRAINT [DF__SPO_Order__Edite__6201025C] DEFAULT ((0)) NOT NULL,
    [EditedDateTime]          DATETIME        CONSTRAINT [DF__SPO_Order__Edite__62F52695] DEFAULT (getdate()) NOT NULL,
    [IsActive]                BIT             CONSTRAINT [DF__SPO_Order__IsAct__63E94ACE] DEFAULT ((0)) NOT NULL,
    [MiniumOrderValue]        DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderType_MiniumOrderValue] DEFAULT ((0)) NOT NULL,
    [MiniumAdvancePercentage] DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderType_MiniumAdvancePercentage] DEFAULT ((0)) NOT NULL,
    [PlaceOrderBeforeDays]    INT             CONSTRAINT [DF_SPO_OrderType_PlaceOrderBeforeDays] DEFAULT ((0)) NOT NULL,
    [AmmendmentBeforeDays]    INT             CONSTRAINT [DF_SPO_OrderType_AmmendmentBeforeDays] DEFAULT ((0)) NOT NULL,
    [PayBeforeDays]           INT             CONSTRAINT [DF_SPO_OrderType_PayBeforeDays] DEFAULT ((0)) NOT NULL,
    [IsAllowAmendment]        BIT             CONSTRAINT [DF_SPO_OrderType_IsAllowAmendment] DEFAULT ((0)) NOT NULL,
    [IsCreditLimitApply]      BIT             CONSTRAINT [DF_SPO_OrderType_IsCreditLimitApply] DEFAULT ((0)) NOT NULL,
    [IsAllowDiscounts]        BIT             CONSTRAINT [DF_SPO_OrderType_IsAllowDiscounts] DEFAULT ((0)) NOT NULL,
    [IsOrderApproval]         BIT             CONSTRAINT [DF_SPO_OrderType_IsOrderApproval] DEFAULT ((0)) NOT NULL,
    [CancelOrderDocCharge]    DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderType_CancelOrderDocCharge] DEFAULT ((0)) NOT NULL
);


GO

