CREATE TABLE [dbo].[LTYC_ContentBlock] (
    [BlockId]          INT            IDENTITY (1, 1) NOT NULL,
    [PropertyId]       INT            NOT NULL,
    [Code]             VARCHAR (60)   NOT NULL,
    [Name]             NVARCHAR (150) NOT NULL,
    [BlockType]        VARCHAR (30)   NOT NULL,
    [BodyHtml]         NVARCHAR (MAX) NOT NULL,
    [ParamsSchemaJson] NVARCHAR (MAX) NULL,
    [IsActive]         BIT            CONSTRAINT [DF_LTYC_ContentBlock_IsActive] DEFAULT ((1)) NOT NULL,
    [IsDeleted]        BIT            CONSTRAINT [DF_LTYC_ContentBlock_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]        INT            NOT NULL,
    [CreatedDate]      DATETIME2 (0)  CONSTRAINT [DF_LTYC_ContentBlock_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]       INT            NULL,
    [ModifiedDate]     DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYC_ContentBlock] PRIMARY KEY CLUSTERED ([BlockId] ASC),
    CONSTRAINT [UQ_LTYC_ContentBlock_Property_Code] UNIQUE NONCLUSTERED ([PropertyId] ASC, [Code] ASC)
);


GO

