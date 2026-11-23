CREATE TABLE [dbo].[LTYC_SegmentMember] (
    [SegmentId]       INT           NOT NULL,
    [MemberId]        INT           NOT NULL,
    [PropertyId]      INT           NOT NULL,
    [AddedAt]         DATETIME2 (0) CONSTRAINT [DF_LTYC_SegmentMember_AddedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [SnapshotVersion] INT           CONSTRAINT [DF_LTYC_SegmentMember_Snapshot] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LTYC_SegmentMember] PRIMARY KEY CLUSTERED ([SegmentId] ASC, [MemberId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_SegmentMember_Member]
    ON [dbo].[LTYC_SegmentMember]([MemberId] ASC)
    INCLUDE([SegmentId], [PropertyId]);


GO

