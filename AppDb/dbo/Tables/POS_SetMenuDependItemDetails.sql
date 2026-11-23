CREATE TABLE [dbo].[POS_SetMenuDependItemDetails] (
    [DependItemDetailsID] INT              IDENTITY (1, 1) NOT NULL,
    [MainItemCode]        VARCHAR (10)     CONSTRAINT [DF__POS_SetMe__MainI__1EEE5C67] DEFAULT ((0)) NOT NULL,
    [LevelCode]           VARCHAR (10)     NOT NULL,
    [LevelItemId]         VARCHAR (10)     CONSTRAINT [DF__POS_SetMe__Level__1FE280A0] DEFAULT ((0)) NOT NULL,
    [DepenItemId]         VARCHAR (10)     CONSTRAINT [DF__POS_SetMe__Depen__20D6A4D9] DEFAULT ((0)) NOT NULL,
    [Price]               DECIMAL (18, 10) CONSTRAINT [DF__POS_SetMe__Price__21CAC912] DEFAULT ((0)) NOT NULL,
    [IsActive]            BIT              CONSTRAINT [DF__POS_SetMe__IsAct__22BEED4B] DEFAULT ((0)) NOT NULL,
    [CreatedUser]         NVARCHAR (50)    NULL,
    [CreatedDate]         DATETIME         NOT NULL,
    [ModifiedUser]        NVARCHAR (50)    NULL,
    [ModifiedDate]        DATETIME         NOT NULL,
    [PropertyId]          INT              DEFAULT ((0)) NOT NULL,
    [WebUpload]           BIT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.POS_SetMenuDependItemDetails] PRIMARY KEY CLUSTERED ([DependItemDetailsID] ASC)
);


GO

