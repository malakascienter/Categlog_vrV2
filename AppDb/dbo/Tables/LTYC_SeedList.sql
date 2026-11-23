CREATE TABLE [dbo].[LTYC_SeedList] (
    [SeedListId]  INT            IDENTITY (1, 1) NOT NULL,
    [PropertyId]  INT            NOT NULL,
    [Name]        NVARCHAR (150) NOT NULL,
    [Description] NVARCHAR (500) NULL,
    [IsActive]    BIT            CONSTRAINT [DF_LTYC_SeedList_IsActive] DEFAULT ((1)) NOT NULL,
    [CreatedBy]   INT            NOT NULL,
    [CreatedDate] DATETIME2 (0)  CONSTRAINT [DF_LTYC_SeedList_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_SeedList] PRIMARY KEY CLUSTERED ([SeedListId] ASC),
    CONSTRAINT [UQ_LTYC_SeedList_Property_Name] UNIQUE NONCLUSTERED ([PropertyId] ASC, [Name] ASC)
);


GO

