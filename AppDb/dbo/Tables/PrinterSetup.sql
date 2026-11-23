CREATE TABLE [dbo].[PrinterSetup] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [Code]               VARCHAR (2)    NOT NULL,
    [Name]               VARCHAR (50)   NULL,
    [Path]               NVARCHAR (MAX) NULL,
    [TicketNo]           INT            NULL,
    [PrintTicket]        BIT            NOT NULL,
    [AlternativePrinter] VARCHAR (50)   NOT NULL,
    [Active]             BIT            NOT NULL,
    [Printer]            VARCHAR (50)   NULL,
    [PropertyId]         INT            NULL,
    [IsUpload]           BIT            CONSTRAINT [DF_PrinterSetup_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]      INT            NULL,
    [CreatedDateTime]    DATETIME       NULL,
    [UpdatedUserId]      INT            NULL,
    [UpdatedDateTime]    DATETIME       NULL,
    CONSTRAINT [PK_PrinterSetup] PRIMARY KEY CLUSTERED ([Id] ASC, [Code] ASC)
);


GO

