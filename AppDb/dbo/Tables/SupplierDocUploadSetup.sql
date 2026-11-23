CREATE TABLE [dbo].[SupplierDocUploadSetup] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [FileType]         VARCHAR (50)  NULL,
    [DocumentTypeName] VARCHAR (MAX) NULL,
    [IsActive]         BIT           NULL,
    [PropertyID]       INT           NULL,
    [SetupCode]        VARCHAR (MAX) NULL,
    CONSTRAINT [PK_SupplierDocUploadSetup] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

