CREATE TABLE [dbo].[DayEndNotApplicableMenuCategories] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [MenuCategory] VARCHAR (20) NULL,
    [IsActive]     BIT          CONSTRAINT [DF_DayEndNotApplicableMenuCategories_IsActive] DEFAULT ((1)) NULL,
    [PropertyID]   INT          NULL
);


GO

