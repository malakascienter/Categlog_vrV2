CREATE TABLE [dbo].[POS_TableList_History] (
    [TableID]          INT          NOT NULL,
    [TableCategoryID]  INT          NOT NULL,
    [TableName]        VARCHAR (50) NOT NULL,
    [IsActive]         BIT          NOT NULL,
    [SequenceID]       INT          NOT NULL,
    [PropertyId]       INT          NULL,
    [IsUpload]         BIT          NULL,
    [MarkAsDelete]     BIT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [CreatedUserID]    INT          NULL,
    [ModifiedDateTime] DATETIME     NULL,
    [ModifiedUserID]   INT          NULL,
    [SysDate]          DATETIME     CONSTRAINT [DF_POS_TableList_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Id]               BIGINT       DEFAULT ((0)) NOT NULL,
    [SeatCount]        INT          DEFAULT ((0)) NOT NULL,
    [AvailableChairs]  INT          DEFAULT ((0)) NOT NULL
);


GO

