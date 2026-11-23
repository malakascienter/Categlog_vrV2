CREATE TABLE [dbo].[POS_TableCategories] (
    [TableCategoryID]   INT          IDENTITY (1, 1) NOT NULL,
    [TableCategoryName] VARCHAR (50) CONSTRAINT [DF_POS_TableCategories_TableCategoryName] DEFAULT ('') NOT NULL,
    [OutletID]          VARCHAR (5)  CONSTRAINT [DF_POS_TableCategories_OutletID] DEFAULT ((0)) NOT NULL,
    [IsActive]          BIT          CONSTRAINT [DF_POS_TableCategories_IsActive] DEFAULT ((1)) NOT NULL,
    [SequenceID]        INT          NOT NULL,
    [IsUpload]          BIT          NULL,
    [PropertyId]        INT          NULL,
    [CreatedDateTime]   DATETIME     CONSTRAINT [DF_POS_TableCategories_CreatedDateTime] DEFAULT (getdate()) NULL,
    [CreatedUserID]     INT          NULL,
    [ModifiedDateTime]  DATETIME     CONSTRAINT [DF_POS_TableCategories_ModifiedDateTime] DEFAULT (getdate()) NULL,
    [ModifiedUserID]    INT          NULL,
    [MarkAsDelete]      BIT          CONSTRAINT [DF_POS_TableCategories_MarkAsDelete] DEFAULT ((0)) NULL,
    [MaxPaxLimit]       INT          DEFAULT ((230)) NOT NULL,
    [IsRevolving]       BIT          NULL,
    [ColorCode]         VARCHAR (20) NULL,
    [ShowMaxPaxCount]   INT          CONSTRAINT [DF_POS_TableCategories_ShowMaxPaxCount] DEFAULT ((0)) NULL,
    [imagePath]         VARCHAR (50) NULL,
    [Id]                AS           ([TableCategoryID]),
    CONSTRAINT [PK_POS_TableCategories] PRIMARY KEY CLUSTERED ([TableCategoryID] ASC)
);


GO

