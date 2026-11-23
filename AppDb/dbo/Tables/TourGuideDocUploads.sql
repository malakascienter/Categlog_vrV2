CREATE TABLE [dbo].[TourGuideDocUploads] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [DocID]                INT           NULL,
    [Module]               VARCHAR (10)  NULL,
    [Type]                 VARCHAR (10)  NULL,
    [SetupCode]            VARCHAR (20)  NULL,
    [SetupID]              INT           NULL,
    [FileName]             VARCHAR (MAX) NULL,
    [CreateduserID]        INT           NOT NULL,
    [CreatedDate]          DATETIME      NULL,
    [IsDelete]             BIT           CONSTRAINT [DF_TourGuideDocUploads_IsDelete] DEFAULT ((0)) NOT NULL,
    [LastModifiedUserID]   INT           NULL,
    [LastModifiedDateTime] DATETIME      NULL
);


GO

