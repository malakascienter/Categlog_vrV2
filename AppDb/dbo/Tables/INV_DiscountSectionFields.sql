CREATE TABLE [dbo].[INV_DiscountSectionFields] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [SectionTypeId]   INT             NOT NULL,
    [FieldCode]       VARCHAR (20)    NOT NULL,
    [Label]           VARCHAR (50)    NOT NULL,
    [Scope]           VARCHAR (10)    NOT NULL,
    [InputType]       VARCHAR (10)    NOT NULL,
    [IsRequired]      BIT             CONSTRAINT [DF_INV_DSF_Req] DEFAULT ((0)) NOT NULL,
    [MinValue]        DECIMAL (18, 2) NULL,
    [MaxValue]        DECIMAL (18, 2) NULL,
    [MaxLength]       INT             NULL,
    [InputFormat]     VARCHAR (10)    CONSTRAINT [DF_INV_DSF_Format] DEFAULT ('ANY') NOT NULL,
    [DefaultValue]    VARCHAR (50)    NULL,
    [EnableWhenAnyOf] VARCHAR (100)   NULL,
    [Width]           VARCHAR (10)    CONSTRAINT [DF_INV_DSF_Width] DEFAULT ('quarter') NOT NULL,
    [SortOrder]       INT             CONSTRAINT [DF_INV_DSF_Sort] DEFAULT ((0)) NOT NULL,
    [IsActive]        BIT             CONSTRAINT [DF_INV_DSF_Active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_INV_DiscountSectionFields] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_INV_DSF_Format] CHECK ([InputFormat]='ALPHANUM' OR [InputFormat]='DIGITS' OR [InputFormat]='ANY'),
    CONSTRAINT [CK_INV_DSF_InputType] CHECK ([InputType]='checkbox' OR [InputType]='number' OR [InputType]='text'),
    CONSTRAINT [CK_INV_DSF_Scope] CHECK ([Scope]='ROW' OR [Scope]='SECTION'),
    CONSTRAINT [CK_INV_DSF_Width] CHECK ([Width]='full' OR [Width]='half' OR [Width]='quarter'),
    CONSTRAINT [FK_INV_DSF_SectionType] FOREIGN KEY ([SectionTypeId]) REFERENCES [dbo].[INV_DiscountSectionTypes] ([Id]),
    CONSTRAINT [UQ_INV_DiscountSectionFields] UNIQUE NONCLUSTERED ([SectionTypeId] ASC, [FieldCode] ASC)
);


GO

