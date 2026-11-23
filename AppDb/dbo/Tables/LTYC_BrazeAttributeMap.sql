CREATE TABLE [dbo].[LTYC_BrazeAttributeMap] (
    [MapId]              INT           IDENTITY (1, 1) NOT NULL,
    [PropertyId]         INT           NOT NULL,
    [AttributeCode]      VARCHAR (60)  NOT NULL,
    [BrazeAttributeName] VARCHAR (100) NOT NULL,
    [DataType]           VARCHAR (20)  NOT NULL,
    [IsActive]           BIT           CONSTRAINT [DF_LTYC_BrazeAttributeMap_IsActive] DEFAULT ((1)) NOT NULL,
    [SortOrder]          INT           CONSTRAINT [DF_LTYC_BrazeAttributeMap_SortOrder] DEFAULT ((0)) NOT NULL,
    [CreatedDate]        DATETIME2 (0) CONSTRAINT [DF_LTYC_BrazeAttributeMap_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_BrazeAttributeMap] PRIMARY KEY CLUSTERED ([MapId] ASC),
    CONSTRAINT [UQ_LTYC_BrazeAttributeMap_Property_Attr] UNIQUE NONCLUSTERED ([PropertyId] ASC, [AttributeCode] ASC)
);


GO

