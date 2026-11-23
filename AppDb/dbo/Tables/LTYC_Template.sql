CREATE TABLE [dbo].[LTYC_Template] (
    [TemplateId]   INT            IDENTITY (1, 1) NOT NULL,
    [PropertyId]   INT            NOT NULL,
    [Code]         VARCHAR (60)   NOT NULL,
    [Name]         NVARCHAR (150) NOT NULL,
    [Channel]      VARCHAR (20)   NOT NULL,
    [VersionNo]    INT            CONSTRAINT [DF_LTYC_Template_VersionNo] DEFAULT ((1)) NOT NULL,
    [Status]       VARCHAR (20)   CONSTRAINT [DF_LTYC_Template_Status] DEFAULT ('DRAFT') NOT NULL,
    [Subject]      NVARCHAR (300) NULL,
    [BodyHtml]     NVARCHAR (MAX) NULL,
    [BodyText]     NVARCHAR (MAX) NULL,
    [BlocksJson]   NVARCHAR (MAX) NULL,
    [ImageUrl]     NVARCHAR (500) NULL,
    [CtaLabel]     NVARCHAR (100) NULL,
    [CtaUrl]       NVARCHAR (500) NULL,
    [DeepLink]     NVARCHAR (500) NULL,
    [IsActive]     BIT            CONSTRAINT [DF_LTYC_Template_IsActive] DEFAULT ((1)) NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_LTYC_Template_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]    INT            NOT NULL,
    [CreatedDate]  DATETIME2 (0)  CONSTRAINT [DF_LTYC_Template_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]   INT            NULL,
    [ModifiedDate] DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYC_Template] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UQ_LTYC_Template_Property_Code_Version] UNIQUE NONCLUSTERED ([PropertyId] ASC, [Code] ASC, [VersionNo] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_Template_Property_Channel]
    ON [dbo].[LTYC_Template]([PropertyId] ASC, [Channel] ASC, [Status] ASC)
    INCLUDE([Code], [Name], [VersionNo]) WHERE ([IsDeleted]=(0));


GO

