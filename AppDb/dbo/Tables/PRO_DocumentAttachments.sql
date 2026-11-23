CREATE TABLE [dbo].[PRO_DocumentAttachments] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [DocId]           INT            NULL,
    [DocTypeID]       INT            NULL,
    [FileName]        NVARCHAR (MAX) NULL,
    [CreatedUserID]   INT            NULL,
    [CreatedDate]     DATETIME       NULL,
    [IsActive]        BIT            NULL,
    [CompanyId]       INT            NULL,
    [DisplayFileName] NVARCHAR (MAX) NULL
);


GO

