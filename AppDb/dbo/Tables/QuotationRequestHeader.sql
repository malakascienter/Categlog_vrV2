CREATE TABLE [dbo].[QuotationRequestHeader] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [PurchaseRequestID]  INT            NULL,
    [CreatedUserID]      INT            NULL,
    [PropertyID]         INT            NULL,
    [CreatedDate]        DATETIME       CONSTRAINT [DF_QuotationRequestHeader_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [DocNo]              NVARCHAR (100) NULL,
    [Status]             CHAR (2)       CONSTRAINT [DF_QuotationRequestHeader_Status] DEFAULT ('P') NULL,
    [filePath]           NVARCHAR (MAX) NULL,
    [IsDocUpload]        BIT            CONSTRAINT [DF_QuotationRequestHeader_IsDocUpload] DEFAULT ((0)) NOT NULL,
    [LastModifiedUserID] INT            NULL,
    [LastModifiedDate]   DATETIME       NULL,
    [RejectedUser]       INT            NULL,
    [RejectedDate]       DATETIME       NULL,
    [RejectedReason]     VARCHAR (MAX)  NULL
);


GO

