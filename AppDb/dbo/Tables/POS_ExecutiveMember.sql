CREATE TABLE [dbo].[POS_ExecutiveMember] (
    [MemberID]                  INT             CONSTRAINT [DF__POS_Execu__Membe__063D5924] DEFAULT ((0)) NOT NULL,
    [MemberName]                VARCHAR (100)   CONSTRAINT [DF__POS_Execu__Membe__07317D5D] DEFAULT ('') NOT NULL,
    [EPFNo]                     VARCHAR (10)    CONSTRAINT [DF__POS_Execu__EPFNo__0825A196] DEFAULT ('') NULL,
    [CreditLimit]               DECIMAL (18, 2) CONSTRAINT [DF__POS_Execu__Credi__0919C5CF] DEFAULT ((0)) NOT NULL,
    [CreditBalance]             DECIMAL (18, 2) CONSTRAINT [DF__POS_Execu__Credi__0A0DEA08] DEFAULT ((0)) NOT NULL,
    [Active]                    BIT             CONSTRAINT [DF__POS_Execu__Activ__0B020E41] DEFAULT ((0)) NOT NULL,
    [DiscountPercentage]        DECIMAL (18, 2) CONSTRAINT [DF__POS_Execu__Disco__0BF6327A] DEFAULT ((0)) NOT NULL,
    [IsExecutivePrice]          BIT             CONSTRAINT [DF_POS_ExecutiveMember_IsExecutivePrice] DEFAULT ((0)) NOT NULL,
    [ChargeHeaderId]            INT             NULL,
    [CreatedUserId]             INT             NULL,
    [CreatedDateTime]           DATETIME        NULL,
    [ModifyUserId]              INT             NULL,
    [ModifiedDateTime]          DATETIME        NULL,
    [IsUpload]                  BIT             CONSTRAINT [DF_POS_ExecutiveMember_IsUpload] DEFAULT ((0)) NULL,
    [PropertyId]                INT             NULL,
    [BSPCode]                   VARCHAR (10)    NULL,
    [ExecutiveMemberCategoryId] INT             CONSTRAINT [DF_POS_ExecutiveMember_ExecutiveMemberCategoryId] DEFAULT ((0)) NOT NULL,
    [Id]                        BIGINT          IDENTITY (1, 1) NOT NULL
);


GO

