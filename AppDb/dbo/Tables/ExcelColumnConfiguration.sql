CREATE TABLE [dbo].[ExcelColumnConfiguration] (
    [Id]                    INT           IDENTITY (1, 1) NOT NULL,
    [TranType]              VARCHAR (5)   NULL,
    [ColumnConfiguration]   VARCHAR (MAX) NULL,
    [DropDownConfiguration] VARCHAR (MAX) NULL,
    [CheckBoxConfiguration] VARCHAR (MAX) NULL,
    [SP_Name]               VARCHAR (50)  NULL,
    [IsActive]              BIT           CONSTRAINT [DF_ExcelColumnConfiguration_IsActive] DEFAULT ((0)) NOT NULL
);


GO

