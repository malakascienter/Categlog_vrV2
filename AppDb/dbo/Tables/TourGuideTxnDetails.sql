CREATE TABLE [dbo].[TourGuideTxnDetails] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [TourGuideTxnHeaderId]  BIGINT          NOT NULL,
    [OrderNo]               VARCHAR (50)    NOT NULL,
    [OrderDate]             DATETIME        NOT NULL,
    [Outlet]                VARCHAR (5)     NOT NULL,
    [PropertyId]            INT             NOT NULL,
    [OrderAmount]           DECIMAL (18, 6) NOT NULL,
    [TourGuideCompaniesPer] DECIMAL (18, 6) NOT NULL,
    [TourGuidePer]          DECIMAL (18, 6) NOT NULL,
    [TourGuideCompaniesId]  INT             NOT NULL,
    [CommissionAmount]      DECIMAL (18, 6) NOT NULL,
    [CreatedUserId]         INT             NULL,
    [CreatedDateTime]       DATETIME        NULL,
    CONSTRAINT [PK_TourGuideTxnDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

