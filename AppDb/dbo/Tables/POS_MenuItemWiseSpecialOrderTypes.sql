CREATE TABLE [dbo].[POS_MenuItemWiseSpecialOrderTypes] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [MenuItemId]   VARCHAR (10) NOT NULL,
    [MenuItemCode] VARCHAR (20) NOT NULL,
    [OrderTypeId]  INT          NOT NULL,
    [PropertyId]   INT          NULL,
    CONSTRAINT [PK_POS_MenuItemWiseSpecialOrderTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

