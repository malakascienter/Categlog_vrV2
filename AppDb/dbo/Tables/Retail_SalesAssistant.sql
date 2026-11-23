CREATE TABLE [dbo].[Retail_SalesAssistant] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [Code]          NVARCHAR (200) NULL,
    [RefNo]         NVARCHAR (200) NULL,
    [IsActive]      BIT            NULL,
    [PropertyID]    INT            NULL,
    [CreatedUserID] INT            NULL,
    [CreatedDate]   DATETIME       NULL,
    [LastModUserID] INT            NULL,
    [LastModDate]   DATETIME       NULL,
    [IsUpload]      BIT            CONSTRAINT [DF_Retail_SalesAssistant_IsUpload] DEFAULT ((0)) NULL
);


GO

