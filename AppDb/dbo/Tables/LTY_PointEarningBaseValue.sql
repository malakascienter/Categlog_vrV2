CREATE TABLE [dbo].[LTY_PointEarningBaseValue] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (MAX) NOT NULL,
    [Description] VARCHAR (MAX) NULL,
    [IsActive]    BIT           CONSTRAINT [DF_LTY_PointEarningBaseValue_IsActive] DEFAULT ((0)) NOT NULL,
    [PropertyId]  INT           NULL,
    CONSTRAINT [PK_LTY_PointEarningBaseValue] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

