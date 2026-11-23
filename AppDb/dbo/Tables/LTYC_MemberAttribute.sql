CREATE TABLE [dbo].[LTYC_MemberAttribute] (
    [AttributeId]      INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]       INT             NOT NULL,
    [AttributeCode]    VARCHAR (50)    NOT NULL,
    [DisplayName]      NVARCHAR (200)  NOT NULL,
    [Description]      NVARCHAR (1000) NULL,
    [DataType]         VARCHAR (20)    CONSTRAINT [DF_LTYC_MemberAttribute_DataType] DEFAULT ('STRING') NOT NULL,
    [InputType]        VARCHAR (20)    CONSTRAINT [DF_LTYC_MemberAttribute_InputType] DEFAULT ('TEXT') NOT NULL,
    [OptionsJson]      NVARCHAR (MAX)  NULL,
    [IsRequired]       BIT             CONSTRAINT [DF_LTYC_MemberAttribute_Required] DEFAULT ((0)) NOT NULL,
    [IsSegmentable]    BIT             CONSTRAINT [DF_LTYC_MemberAttribute_Segmentable] DEFAULT ((1)) NOT NULL,
    [IsPersonalisable] BIT             CONSTRAINT [DF_LTYC_MemberAttribute_Personalisable] DEFAULT ((0)) NOT NULL,
    [SortOrder]        INT             CONSTRAINT [DF_LTYC_MemberAttribute_Sort] DEFAULT ((100)) NOT NULL,
    [IsActive]         BIT             CONSTRAINT [DF_LTYC_MemberAttribute_Active] DEFAULT ((1)) NOT NULL,
    [IsDeleted]        BIT             CONSTRAINT [DF_LTYC_MemberAttribute_Deleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]        INT             NOT NULL,
    [CreatedDate]      DATETIME2 (3)   CONSTRAINT [DF_LTYC_MemberAttribute_Created] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]       INT             NULL,
    [ModifiedDate]     DATETIME2 (3)   NULL,
    CONSTRAINT [PK_LTYC_MemberAttribute] PRIMARY KEY CLUSTERED ([AttributeId] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYC_MemberAttribute_Code]
    ON [dbo].[LTYC_MemberAttribute]([PropertyId] ASC, [AttributeCode] ASC) WHERE ([IsDeleted]=(0));


GO

