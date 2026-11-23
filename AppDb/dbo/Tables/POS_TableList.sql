CREATE TABLE [dbo].[POS_TableList] (
    [TableID]          INT          IDENTITY (1, 1) NOT NULL,
    [TableCategoryID]  INT          NOT NULL,
    [TableName]        VARCHAR (50) CONSTRAINT [DF_POS_TableList_TableName] DEFAULT ('') NOT NULL,
    [IsActive]         BIT          CONSTRAINT [DF_POS_TableList_IsActive] DEFAULT ((1)) NOT NULL,
    [SequenceID]       INT          NOT NULL,
    [PropertyId]       INT          NULL,
    [MarkAsDelete]     BIT          NULL,
    [IsUpload]         BIT          NULL,
    [CreatedDateTime]  DATETIME     CONSTRAINT [DF_POS_TableList_CreatedDateTime] DEFAULT (getdate()) NULL,
    [CreatedUserID]    INT          NULL,
    [ModifiedDateTime] DATETIME     CONSTRAINT [DF_POS_TableList_ModifiedDateTime] DEFAULT (getdate()) NULL,
    [ModifiedUserID]   INT          NULL,
    [Id]               AS           ([TableID]),
    [SeatCount]        INT          DEFAULT ((0)) NOT NULL,
    [AvailableChairs]  INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_TableList] PRIMARY KEY CLUSTERED ([TableID] ASC)
);


GO

