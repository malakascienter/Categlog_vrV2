CREATE TABLE [dbo].[POS_ItemWastageDetails] (
    [Id]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [DocNo]            VARCHAR (10)  NULL,
    [Outlet]           VARCHAR (5)   NULL,
    [BusinessDate]     DATE          NULL,
    [Qty]              MONEY         NULL,
    [ItemCode]         VARCHAR (10)  NULL,
    [Remark]           VARCHAR (200) NULL,
    [PropertyId]       INT           NULL,
    [CreatedUserId]    INT           NULL,
    [CreatedDateTime]  DATETIME      NULL,
    [ModifiedUserId]   INT           NULL,
    [ModifiedDateTime] DATETIME      NULL,
    [Price]            MONEY         DEFAULT ((0)) NOT NULL,
    [WastageTypeId]    INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_ItemWastageDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

