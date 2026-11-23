CREATE TABLE [dbo].[INV_ValidationModeSections] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [ValidationModeId] INT           NOT NULL,
    [SectionTypeId]    INT           NOT NULL,
    [IsRequired]       BIT           CONSTRAINT [DF_INV_VMS_Req] DEFAULT ((0)) NOT NULL,
    [SortOrder]        INT           CONSTRAINT [DF_INV_VMS_Sort] DEFAULT ((0)) NOT NULL,
    [RequiredMessage]  VARCHAR (150) NULL,
    [PropertyId]       INT           NOT NULL,
    CONSTRAINT [PK_INV_ValidationModeSections] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_INV_VMS_SectionType] FOREIGN KEY ([SectionTypeId]) REFERENCES [dbo].[INV_DiscountSectionTypes] ([Id]),
    CONSTRAINT [UQ_INV_ValidationModeSections] UNIQUE NONCLUSTERED ([ValidationModeId] ASC, [SectionTypeId] ASC)
);


GO

