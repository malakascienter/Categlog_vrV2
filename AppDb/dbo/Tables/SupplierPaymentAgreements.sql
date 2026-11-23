CREATE TABLE [dbo].[SupplierPaymentAgreements] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
    [Creditperiod]     INT            NOT NULL,
    [AdvanceRatio]     REAL           NOT NULL,
    [OnDeliverRatio]   REAL           NOT NULL,
    [PayMethodID]      INT            NOT NULL,
    [BillingFrequency] INT            NOT NULL,
    [IsActive]         BIT            NOT NULL,
    [IPAddress]        NVARCHAR (MAX) NULL,
    [CreatedUserID]    INT            NOT NULL,
    [LastModUserID]    INT            NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [LastModDate]      DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.SupplierPaymentAgreements] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

