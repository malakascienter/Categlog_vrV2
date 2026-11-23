CREATE TABLE [dbo].[SendReportMailRecipient] (
    [Id]         INT            NULL,
    [Position]   VARCHAR (200)  NULL,
    [Name]       VARCHAR (500)  NULL,
    [Email]      NVARCHAR (500) NULL,
    [IsDefault]  BIT            CONSTRAINT [DF_SendReportMailRecipient_IsDefault] DEFAULT ((0)) NOT NULL,
    [IsCC]       BIT            CONSTRAINT [DF_SendReportMailRecipient_IsCC] DEFAULT ((0)) NOT NULL,
    [ReportType] VARCHAR (50)   NULL
);


GO

