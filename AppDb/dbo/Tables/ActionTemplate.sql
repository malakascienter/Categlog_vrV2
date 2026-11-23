CREATE TABLE [dbo].[ActionTemplate] (
    [ID]              INT          CONSTRAINT [DF_ActionTemplate_ID] DEFAULT ((0)) NOT NULL,
    [Name]            VARCHAR (50) CONSTRAINT [DF_ActionTemplate_Name] DEFAULT ('') NOT NULL,
    [ActionButtonID]  INT          CONSTRAINT [DF_ActionTemplate_ActionButtonID] DEFAULT ((0)) NOT NULL,
    [OrderSeq]        INT          CONSTRAINT [DF_ActionTemplate_OrderSeq] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] NCHAR (10)   NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          NULL,
    CONSTRAINT [PK_ActionTemplate] PRIMARY KEY CLUSTERED ([ID] ASC, [ActionButtonID] ASC)
);


GO

