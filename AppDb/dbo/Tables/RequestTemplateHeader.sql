CREATE TABLE [dbo].[RequestTemplateHeader] (
    [TemplateHeaderID]    INT            IDENTITY (1, 1) NOT NULL,
    [Name]                VARCHAR (200)  NULL,
    [IsActive]            BIT            NOT NULL,
    [CreatedUserID]       INT            NOT NULL,
    [ModifiedUserID]      INT            NOT NULL,
    [CreatedDate]         DATETIME       CONSTRAINT [DF_RequestTemplateHeader_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]        DATETIME       CONSTRAINT [DF_RequestTemplateHeader_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [PropertyId]          INT            NULL,
    [IsHouseKeepingAPI]   BIT            CONSTRAINT [DF_RequestTemplateHeader_IsHouseKeepingAPI] DEFAULT ((0)) NULL,
    [TransactionTypeCode] NVARCHAR (MAX) NULL,
    [LocationList]        NVARCHAR (MAX) NULL
);


GO

