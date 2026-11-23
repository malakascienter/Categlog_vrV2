CREATE TABLE [dbo].[PaymentTermsDetails] (
    [PaymentTermID] INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]    INT            NOT NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.PaymentTermsDetails] PRIMARY KEY CLUSTERED ([PaymentTermID] ASC)
);


GO

