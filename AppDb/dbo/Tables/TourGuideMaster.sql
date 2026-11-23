CREATE TABLE [dbo].[TourGuideMaster] (
    [Id]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [TourGuideCompaniesId] BIGINT         NOT NULL,
    [Code]                 VARCHAR (20)   NOT NULL,
    [Description]          VARCHAR (200)  NOT NULL,
    [NIC]                  VARCHAR (20)   NOT NULL,
    [ContactNo]            VARCHAR (20)   NOT NULL,
    [Email]                VARCHAR (50)   NOT NULL,
    [IsActive]             BIT            CONSTRAINT [DF_TourGuideMaster_IsActive] DEFAULT ((0)) NOT NULL,
    [IsDelete]             BIT            CONSTRAINT [DF_TourGuideMaster_IsDelete] DEFAULT ((0)) NOT NULL,
    [PropertyId]           INT            CONSTRAINT [DF_TourGuideMaster_PropertyId] DEFAULT ((0)) NOT NULL,
    [IsUpload]             BIT            CONSTRAINT [DF_TourGuideMaster_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]        INT            NULL,
    [CreatedDateTime]      DATETIME       NULL,
    [LastModifiedUserID]   INT            NULL,
    [LastModifiedDateTime] DATETIME       NULL,
    [CommissionPercentage] MONEY          DEFAULT ((0)) NOT NULL,
    [Module]               VARCHAR (1)    CONSTRAINT [DF_TourGuideMaster_ModuleType] DEFAULT ('P') NOT NULL,
    [TourGuideLicense]     NVARCHAR (MAX) NULL,
    [Address]              NVARCHAR (MAX) NULL,
    [BankName]             NVARCHAR (MAX) NULL,
    [Branch]               NVARCHAR (MAX) NULL,
    [BankAccount]          NVARCHAR (MAX) NULL,
    [TourGuideTypeID]      INT            NULL,
    [IsApproved]           BIT            CONSTRAINT [DF_TourGuideMaster_IsApproved] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TourGuideMaster] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

