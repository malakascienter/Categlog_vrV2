CREATE TABLE [dbo].[DocumentWiseAttachments_Log] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [TableID]       INT            NOT NULL,
    [DocId]         INT            NOT NULL,
    [DocTypeID]     INT            NOT NULL,
    [FileName]      NVARCHAR (MAX) NOT NULL,
    [CreatedUserID] INT            NOT NULL,
    [CreatedDate]   DATE           NOT NULL,
    [DeletedUser]   INT            NOT NULL,
    [DeletedDate]   DATE           NOT NULL
);


GO

