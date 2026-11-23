CREATE TABLE [dbo].[BOQHeaders] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [ProjectID]           INT             NOT NULL,
    [BOQDate]             DATETIME        NOT NULL,
    [Approve]             BIT             NOT NULL,
    [ApprovedUserID]      INT             NOT NULL,
    [ApprovedDate]        DATETIME        NOT NULL,
    [CurrentVersion]      INT             NOT NULL,
    [isDisRate]           BIT             NOT NULL,
    [DisValue]            DECIMAL (18, 2) NOT NULL,
    [SundryValue]         DECIMAL (18, 2) NOT NULL,
    [BOQCode]             NVARCHAR (MAX)  NULL,
    [AdditonalBOQFlag]    BIT             DEFAULT ((0)) NOT NULL,
    [IsPercentageOrValue] BIT             DEFAULT ((0)) NOT NULL,
    [DiscountPercentage]  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DiscountValue]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [BOQName]             NVARCHAR (MAX)  NULL,
    [BOQStatus]           INT             DEFAULT ((0)) NOT NULL,
    [VersionNo]           INT             DEFAULT ((0)) NOT NULL,
    [Finalized]           BIT             DEFAULT ((0)) NOT NULL,
    [MainBoqId]           INT             DEFAULT ((0)) NOT NULL,
    [OHPmaterial]         DECIMAL (18, 2) NULL,
    [OHPlabour]           DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_dbo.BOQHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

