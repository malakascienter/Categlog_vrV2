CREATE TABLE [dbo].[CancelSuppliersRequest] (
    [Id]              INT            NOT NULL,
    [PropertyID]      INT            NOT NULL,
    [Name]            NVARCHAR (100) NULL,
    [Address1]        NVARCHAR (200) NULL,
    [Email]           NVARCHAR (255) NULL,
    [Telephone1]      NVARCHAR (15)  NULL,
    [IsApprove]       BIT            NULL,
    [CreatedUserID]   INT            NOT NULL,
    [LastModUserID]   INT            NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [LastModDate]     DATETIME       NOT NULL,
    [VatNo]           VARCHAR (150)  NULL,
    [logDate]         DATE           DEFAULT (getdate()) NOT NULL,
    [CancelledUserID] INT            NULL
);


GO

