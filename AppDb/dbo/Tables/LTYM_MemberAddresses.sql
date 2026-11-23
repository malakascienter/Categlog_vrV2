CREATE TABLE [dbo].[LTYM_MemberAddresses] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [MemberId]     INT            NOT NULL,
    [Label]        NVARCHAR (50)  NOT NULL,
    [AddressLine1] NVARCHAR (200) NOT NULL,
    [AddressLine2] NVARCHAR (200) NULL,
    [City]         NVARCHAR (100) NULL,
    [ProvinceId]   INT            NULL,
    [CountryId]    INT            NULL,
    [ContactNo]    VARCHAR (15)   NULL,
    [IsDefault]    BIT            CONSTRAINT [DF_LTYM_MemberAddresses_IsDefault] DEFAULT ((0)) NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_LTYM_MemberAddresses_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedAt]    DATETIME2 (0)  CONSTRAINT [DF_LTYM_MemberAddresses_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]    DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYM_MemberAddresses] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYM_MemberAddresses_Member]
    ON [dbo].[LTYM_MemberAddresses]([MemberId] ASC, [IsDeleted] ASC);


GO

