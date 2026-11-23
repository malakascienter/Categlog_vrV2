CREATE TABLE [dbo].[LTYC_SegmentRule] (
    [RuleId]        INT            IDENTITY (1, 1) NOT NULL,
    [SegmentId]     INT            NOT NULL,
    [ParentRuleId]  INT            NULL,
    [NodeKind]      VARCHAR (10)   NOT NULL,
    [LogicalOp]     VARCHAR (3)    NULL,
    [AttributeCode] VARCHAR (60)   NULL,
    [Operator]      VARCHAR (30)   NULL,
    [ValueJson]     NVARCHAR (MAX) NULL,
    [SortOrder]     INT            CONSTRAINT [DF_LTYC_SegmentRule_SortOrder] DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME2 (0)  CONSTRAINT [DF_LTYC_SegmentRule_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_SegmentRule] PRIMARY KEY CLUSTERED ([RuleId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_SegmentRule_Segment_Parent]
    ON [dbo].[LTYC_SegmentRule]([SegmentId] ASC, [ParentRuleId] ASC, [SortOrder] ASC)
    INCLUDE([NodeKind], [LogicalOp], [AttributeCode], [Operator]);


GO

