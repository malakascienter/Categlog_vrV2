CREATE TABLE [dbo].[LTYJ_Node] (
    [NodeId]      INT            IDENTITY (1, 1) NOT NULL,
    [VersionId]   INT            NOT NULL,
    [NodeKey]     VARCHAR (50)   NOT NULL,
    [NodeType]    VARCHAR (30)   NOT NULL,
    [Label]       NVARCHAR (150) NULL,
    [ConfigJson]  NVARCHAR (MAX) NULL,
    [PosX]        DECIMAL (9, 2) CONSTRAINT [DF_LTYJ_Node_PosX] DEFAULT ((0)) NOT NULL,
    [PosY]        DECIMAL (9, 2) CONSTRAINT [DF_LTYJ_Node_PosY] DEFAULT ((0)) NOT NULL,
    [CreatedDate] DATETIME2 (0)  CONSTRAINT [DF_LTYJ_Node_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYJ_Node] PRIMARY KEY CLUSTERED ([NodeId] ASC),
    CONSTRAINT [UQ_LTYJ_Node_Version_Key] UNIQUE NONCLUSTERED ([VersionId] ASC, [NodeKey] ASC)
);


GO

