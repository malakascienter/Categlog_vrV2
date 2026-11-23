CREATE TABLE [dbo].[LTYC_SegmentAttribute] (
    [AttributeCode]    VARCHAR (60)   NOT NULL,
    [DisplayName]      NVARCHAR (100) NOT NULL,
    [Category]         VARCHAR (30)   NOT NULL,
    [DataType]         VARCHAR (20)   NOT NULL,
    [AllowedOperators] VARCHAR (300)  NOT NULL,
    [SqlExpression]    NVARCHAR (500) NOT NULL,
    [SourceAlias]      VARCHAR (20)   NOT NULL,
    [LookupSql]        NVARCHAR (500) NULL,
    [IsBrazeSyncable]  BIT            CONSTRAINT [DF_LTYC_SegmentAttribute_Braze] DEFAULT ((0)) NOT NULL,
    [IsPersonalisable] BIT            CONSTRAINT [DF_LTYC_SegmentAttribute_Personal] DEFAULT ((0)) NOT NULL,
    [SortOrder]        INT            CONSTRAINT [DF_LTYC_SegmentAttribute_SortOrder] DEFAULT ((0)) NOT NULL,
    [IsActive]         BIT            CONSTRAINT [DF_LTYC_SegmentAttribute_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_LTYC_SegmentAttribute] PRIMARY KEY CLUSTERED ([AttributeCode] ASC)
);


GO

