CREATE TABLE [dbo].[INV_DiscountSectionTypes] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [SectionCode]    VARCHAR (20)   NOT NULL,
    [Title]          VARCHAR (50)   NOT NULL,
    [Icon]           VARCHAR (30)   NULL,
    [Width]          VARCHAR (10)   CONSTRAINT [DF_INV_DST_Width] DEFAULT ('half') NOT NULL,
    [ControlType]    VARCHAR (10)   NOT NULL,
    [DropdownSp]     NVARCHAR (128) NULL,
    [Placeholder]    VARCHAR (100)  NULL,
    [AllowAddAll]    BIT            CONSTRAINT [DF_INV_DST_AddAll] DEFAULT ((1)) NOT NULL,
    [MaxRows]        INT            NULL,
    [ValueMaxLength] INT            NULL,
    [ValueFormat]    VARCHAR (10)   CONSTRAINT [DF_INV_DST_Format] DEFAULT ('ANY') NOT NULL,
    [SortOrder]      INT            CONSTRAINT [DF_INV_DST_Sort] DEFAULT ((0)) NOT NULL,
    [IsActive]       BIT            CONSTRAINT [DF_INV_DST_Active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_INV_DiscountSectionTypes] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_INV_DST_ControlType] CHECK ([ControlType]='GRID' OR [ControlType]='INPUT' OR [ControlType]='DROPDOWN'),
    CONSTRAINT [CK_INV_DST_DropdownNeeded] CHECK (([ControlType]='GRID' OR [ControlType]='DROPDOWN') AND [DropdownSp] IS NOT NULL OR [ControlType]='INPUT' AND [DropdownSp] IS NULL),
    CONSTRAINT [CK_INV_DST_DropdownSp] CHECK ([DropdownSp] like 'SP[_]DiscountLookup[_]%'),
    CONSTRAINT [CK_INV_DST_Format] CHECK ([ValueFormat]='ALPHANUM' OR [ValueFormat]='DIGITS' OR [ValueFormat]='ANY'),
    CONSTRAINT [CK_INV_DST_Width] CHECK ([Width]='full' OR [Width]='half'),
    CONSTRAINT [UQ_INV_DiscountSectionTypes_Code] UNIQUE NONCLUSTERED ([SectionCode] ASC)
);


GO

