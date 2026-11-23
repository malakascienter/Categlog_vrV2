CREATE TABLE [dbo].[Documents] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [PartnerType]   VARCHAR (MAX) NOT NULL,
    [PartnerTypeId] INT           NOT NULL,
    [DocTyprId]     INT           NOT NULL,
    [UploadDate]    DATETIME      NOT NULL,
    [UserId]        INT           NOT NULL,
    [FilePath]      VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

