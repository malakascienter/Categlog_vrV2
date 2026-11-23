CREATE TABLE [dbo].[LTY_ValidationModes] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Code]                VARCHAR (10)  NULL,
    [Description]         VARCHAR (MAX) NULL,
    [PropertyId]          INT           NOT NULL,
    [IsActive]            BIT           CONSTRAINT [DF_LTY_ValidationModes_IsActive] DEFAULT ((0)) NOT NULL,
    [IsDiscount]          BIT           CONSTRAINT [DF_LTY_ValidationModes_IsDiscount] DEFAULT ((0)) NOT NULL,
    [IsPointCount]        BIT           CONSTRAINT [DF_LTY_ValidationModes_IsPointCount] DEFAULT ((0)) NOT NULL,
    [IsMultipleSelection] BIT           CONSTRAINT [DF_LTY_ValidationModes_IsMultipleSelection] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LTY_ValidationModes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

