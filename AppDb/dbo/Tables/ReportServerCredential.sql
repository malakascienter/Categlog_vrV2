CREATE TABLE [dbo].[ReportServerCredential] (
    [Id]                   INT            NULL,
    [ReportServerURL]      NVARCHAR (MAX) NULL,
    [ReportServerUserName] NVARCHAR (500) NULL,
    [ReportServerPassword] NVARCHAR (500) NULL,
    [IsActive]             BIT            NULL,
    [IsCredentials]        BIT            CONSTRAINT [DF_ReportServerCredential_IsCredentials] DEFAULT ((0)) NOT NULL
);


GO

