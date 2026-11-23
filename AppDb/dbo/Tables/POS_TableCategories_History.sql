CREATE TABLE [dbo].[POS_TableCategories_History] (
    [TableCategoryID]   INT          NOT NULL,
    [TableCategoryName] VARCHAR (50) NOT NULL,
    [OutletID]          VARCHAR (5)  NOT NULL,
    [IsActive]          BIT          NOT NULL,
    [SequenceID]        INT          NOT NULL,
    [IsUpload]          BIT          NULL,
    [PropertyId]        INT          NULL,
    [CreatedDateTime]   DATETIME     NULL,
    [CreatedUserID]     INT          NULL,
    [ModifiedDateTime]  DATETIME     NULL,
    [ModifiedUserID]    INT          NULL,
    [SysDate]           DATETIME     NULL,
    [MarkAsDelete]      BIT          CONSTRAINT [DF_POS_TableCategories_History_MarkAsDelete] DEFAULT ((0)) NULL,
    [MaxPaxLimit]       INT          DEFAULT ((230)) NOT NULL,
    [imagePath]         VARCHAR (50) NULL,
    [ShowMaxPaxCount]   INT          CONSTRAINT [DF_POS_TableCategories_History_ShowMaxPaxCount] DEFAULT ((0)) NULL,
    [IsRevolving]       BIT          NULL,
    [ColorCode]         VARCHAR (20) NULL,
    [Id]                BIGINT       DEFAULT ((0)) NOT NULL
);


GO

