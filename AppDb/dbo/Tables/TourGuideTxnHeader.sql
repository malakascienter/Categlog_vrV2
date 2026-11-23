CREATE TABLE [dbo].[TourGuideTxnHeader] (
    [Id]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [DocumentNo]      VARCHAR (20)    NOT NULL,
    [DocumentDate]    DATETIME        NOT NULL,
    [TourGuideId]     BIGINT          NOT NULL,
    [TotalAmount]     DECIMAL (18, 2) NOT NULL,
    [Remark]          VARCHAR (150)   CONSTRAINT [DF_TourGuideTxnHeader_Remark] DEFAULT ('') NOT NULL,
    [PropertyId]      INT             CONSTRAINT [DF_TourGuideTxnHeader_PropertyId] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT             NULL,
    [CreatedDateTime] DATETIME        NULL
);


GO

