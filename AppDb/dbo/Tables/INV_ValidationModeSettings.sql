CREATE TABLE [dbo].[INV_ValidationModeSettings] (
    [ValidationModeId] INT           NOT NULL,
    [AutoApplyDefault] BIT           CONSTRAINT [DF_INV_VMSet_AutoApply] DEFAULT ((0)) NOT NULL,
    [SaveCodeInHeader] BIT           CONSTRAINT [DF_INV_VMSet_SaveCode] DEFAULT ((1)) NOT NULL,
    [HintText]         VARCHAR (200) NULL,
    [SortOrder]        INT           CONSTRAINT [DF_INV_VMSet_Sort] DEFAULT ((0)) NOT NULL,
    [IsActive]         BIT           CONSTRAINT [DF_INV_VMSet_Active] DEFAULT ((1)) NOT NULL,
    [PropertyId]       INT           NOT NULL,
    CONSTRAINT [PK_INV_ValidationModeSettings] PRIMARY KEY CLUSTERED ([ValidationModeId] ASC)
);


GO

