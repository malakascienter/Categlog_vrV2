CREATE TABLE [dbo].[TourGuideDocUpload_Setup] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [Code]             VARCHAR (10)  NULL,
    [FileType]         VARCHAR (50)  NULL,
    [DocumentTypeName] VARCHAR (MAX) NULL,
    [Module]           VARCHAR (10)  NULL,
    [Type]             VARCHAR (10)  NULL,
    [IsActive]         BIT           NULL,
    [PropertyID]       INT           NOT NULL
);


GO

