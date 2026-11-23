CREATE TABLE [dbo].[LTYC_SeedMember] (
    [SeedMemberId] INT            IDENTITY (1, 1) NOT NULL,
    [SeedListId]   INT            NOT NULL,
    [MemberId]     INT            NULL,
    [Email]        NVARCHAR (300) NULL,
    [MobileNo]     VARCHAR (50)   NULL,
    [Label]        NVARCHAR (150) NULL,
    [CreatedDate]  DATETIME2 (0)  CONSTRAINT [DF_LTYC_SeedMember_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_SeedMember] PRIMARY KEY CLUSTERED ([SeedMemberId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_SeedMember_List]
    ON [dbo].[LTYC_SeedMember]([SeedListId] ASC)
    INCLUDE([MemberId], [Email], [MobileNo]);


GO

