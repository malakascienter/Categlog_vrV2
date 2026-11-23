CREATE TABLE [dbo].[LTYM_MemberFavorites] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [MemberId]   INT            NOT NULL,
    [ItemCode]   VARCHAR (50)   NOT NULL,
    [ItemName]   NVARCHAR (200) NOT NULL,
    [OutletCode] VARCHAR (20)   NULL,
    [CreatedAt]  DATETIME2 (0)  CONSTRAINT [DF_LTYM_MemberFavorites_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYM_MemberFavorites] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_LTYM_MemberFavorites_Member_Item] UNIQUE NONCLUSTERED ([MemberId] ASC, [ItemCode] ASC)
);


GO

