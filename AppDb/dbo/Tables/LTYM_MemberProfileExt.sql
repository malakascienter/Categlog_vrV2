CREATE TABLE [dbo].[LTYM_MemberProfileExt] (
    [MemberId]     INT            NOT NULL,
    [CallingName]  NVARCHAR (100) NULL,
    [Anniversary]  NVARCHAR (50)  NULL,
    [NIC]          VARCHAR (50)   NULL,
    [ImagePath]    NVARCHAR (500) NULL,
    [CardNo]       VARCHAR (20)   NULL,
    [TitleId]      INT            NULL,
    [AddressLine1] NVARCHAR (200) NULL,
    [AddressLine2] NVARCHAR (200) NULL,
    [City]         NVARCHAR (100) NULL,
    [ProvinceId]   INT            NULL,
    [CountryId]    INT            NULL,
    [UpdatedAt]    DATETIME2 (0)  CONSTRAINT [DF_LTYM_MemberProfileExt_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYM_MemberProfileExt] PRIMARY KEY CLUSTERED ([MemberId] ASC)
);


GO

