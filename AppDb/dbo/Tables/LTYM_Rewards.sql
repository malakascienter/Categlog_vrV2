CREATE TABLE [dbo].[LTYM_Rewards] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (150)  NOT NULL,
    [Description]   NVARCHAR (500)  NULL,
    [Category]      VARCHAR (50)    CONSTRAINT [DF_LTYM_Rewards_Category] DEFAULT ('GENERAL') NOT NULL,
    [PointsCost]    DECIMAL (18, 2) NOT NULL,
    [DiscountValue] DECIMAL (18, 4) NOT NULL,
    [IsPercentage]  BIT             NOT NULL,
    [ValidityDays]  INT             CONSTRAINT [DF_LTYM_Rewards_ValidityDays] DEFAULT ((30)) NOT NULL,
    [ImagePath]     NVARCHAR (500)  NULL,
    [IsActive]      BIT             CONSTRAINT [DF_LTYM_Rewards_IsActive] DEFAULT ((1)) NOT NULL,
    [StartDate]     DATETIME2 (0)   NULL,
    [EndDate]       DATETIME2 (0)   NULL,
    [CreatedAt]     DATETIME2 (0)   CONSTRAINT [DF_LTYM_Rewards_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]     DATETIME2 (0)   NULL,
    CONSTRAINT [PK_LTYM_Rewards] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYM_Rewards_Active]
    ON [dbo].[LTYM_Rewards]([IsActive] ASC)
    INCLUDE([StartDate], [EndDate]);


GO

