CREATE TABLE [dbo].[POS_DocumentType] (
    [DocTypeID]    TINYINT       CONSTRAINT [DF_POS_DocumentType_DocTypeID] DEFAULT ((0)) NOT NULL,
    [DocumentName] VARCHAR (100) CONSTRAINT [DF_POS_DocumentType_DocumentName] DEFAULT ('') NOT NULL,
    [PropertyId]   INT           CONSTRAINT [DF_POS_DocumentType_PropertyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_DocumentType] PRIMARY KEY CLUSTERED ([DocTypeID] ASC)
);


GO

