CREATE TABLE [dbo].[TourGuideCompaniesWiseDocument] (
    [Id]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [TourGuideCompaniesId] BIGINT        NOT NULL,
    [DocumentName]         VARCHAR (500) NOT NULL,
    [IsActive]             BIT           CONSTRAINT [DF_TourGuideCompaniesWiseDocument_IsActive] DEFAULT ((0)) NOT NULL,
    [SysDate]              DATETIME      CONSTRAINT [DF_TourGuideCompaniesWiseDocument_SysDate] DEFAULT (getdate()) NOT NULL,
    [CreatedUserId]        INT           NOT NULL,
    [DocumentDisplayName]  VARCHAR (500) DEFAULT ('') NOT NULL,
    [PropertyId]           INT           DEFAULT ((0)) NOT NULL
);


GO

