CREATE TABLE [dbo].[POS_ComplimentaryTypes] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [ComplimentaryType] VARCHAR (100) CONSTRAINT [DF__POS_Compl__Compl__6CEE02BA] DEFAULT ('') NOT NULL,
    [PayType]           VARCHAR (2)   CONSTRAINT [DF__POS_Compl__PayTy__6DE226F3] DEFAULT ('') NOT NULL,
    [Active]            BIT           CONSTRAINT [DF__POS_Compl__Activ__6ED64B2C] DEFAULT ((0)) NOT NULL,
    [SortOrder]         TINYINT       CONSTRAINT [DF__POS_Compl__SortO__6FCA6F65] DEFAULT ((0)) NOT NULL,
    [ChargeHeaderID]    INT           CONSTRAINT [DF__POS_Compl__Charg__70BE939E] DEFAULT ((0)) NOT NULL,
    [IsCustom]          BIT           CONSTRAINT [DF__POS_Compl__IsCus__71B2B7D7] DEFAULT ((0)) NOT NULL
);


GO

