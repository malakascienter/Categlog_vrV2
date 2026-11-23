CREATE TABLE [dbo].[SupplierDocUploads] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [SupplierReqID]        INT           NULL,
    [Type]                 VARCHAR (10)  NULL,
    [SetupID]              INT           NULL,
    [FileName]             VARCHAR (MAX) NULL,
    [CreateduserID]        INT           NULL,
    [CreatedDate]          DATETIME      NULL,
    [IsDelete]             BIT           NULL,
    [LastModifiedUserID]   INT           NULL,
    [LastModifiedDateTime] DATETIME      NULL,
    [SupplierID]           INT           CONSTRAINT [DF_SupplierDocUploads_SupplierID] DEFAULT ((0)) NULL,
    [SetupCode]            VARCHAR (MAX) NULL,
    CONSTRAINT [PK_SupplierDocUploads] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

