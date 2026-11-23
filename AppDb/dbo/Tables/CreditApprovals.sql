CREATE TABLE [dbo].[CreditApprovals] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [CRNumber]       NVARCHAR (MAX)  NULL,
    [CustomerId]     INT             NOT NULL,
    [Amount]         DECIMAL (18, 2) NOT NULL,
    [DocumentStatus] NVARCHAR (MAX)  NULL,
    [IsApproved]     BIT             NOT NULL,
    [IPAddress]      NVARCHAR (MAX)  NULL,
    [CreatedUserID]  INT             NOT NULL,
    [LastModUserID]  INT             NOT NULL,
    [CreatedDate]    DATETIME        NOT NULL,
    [LastModDate]    DATETIME        NOT NULL,
    [PropertyId]     INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.CreditApprovals] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

