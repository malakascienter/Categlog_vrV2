CREATE TABLE [dbo].[LTYJ_Edge] (
    [EdgeId]      INT           IDENTITY (1, 1) NOT NULL,
    [VersionId]   INT           NOT NULL,
    [FromNodeKey] VARCHAR (50)  NOT NULL,
    [ToNodeKey]   VARCHAR (50)  NOT NULL,
    [BranchKey]   VARCHAR (20)  CONSTRAINT [DF_LTYJ_Edge_BranchKey] DEFAULT ('DEFAULT') NOT NULL,
    [SortOrder]   INT           CONSTRAINT [DF_LTYJ_Edge_SortOrder] DEFAULT ((0)) NOT NULL,
    [CreatedDate] DATETIME2 (0) CONSTRAINT [DF_LTYJ_Edge_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYJ_Edge] PRIMARY KEY CLUSTERED ([EdgeId] ASC),
    CONSTRAINT [UQ_LTYJ_Edge_Version_From_Branch] UNIQUE NONCLUSTERED ([VersionId] ASC, [FromNodeKey] ASC, [BranchKey] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_Edge_Version_From]
    ON [dbo].[LTYJ_Edge]([VersionId] ASC, [FromNodeKey] ASC)
    INCLUDE([ToNodeKey], [BranchKey]);


GO

