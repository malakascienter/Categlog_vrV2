CREATE TABLE [dbo].[LTYC_MemberAttributeValue] (
    [MemberId]     INT            NOT NULL,
    [AttributeId]  INT            NOT NULL,
    [PropertyId]   INT            NOT NULL,
    [ValueText]    NVARCHAR (MAX) NULL,
    [ModifiedBy]   INT            NULL,
    [ModifiedDate] DATETIME2 (3)  CONSTRAINT [DF_LTYC_MemberAttributeValue_Modified] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_MemberAttributeValue] PRIMARY KEY CLUSTERED ([MemberId] ASC, [AttributeId] ASC),
    CONSTRAINT [FK_LTYC_MemberAttributeValue_Attribute] FOREIGN KEY ([AttributeId]) REFERENCES [dbo].[LTYC_MemberAttribute] ([AttributeId])
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_MemberAttributeValue_Attribute]
    ON [dbo].[LTYC_MemberAttributeValue]([AttributeId] ASC, [PropertyId] ASC)
    INCLUDE([MemberId]);


GO

