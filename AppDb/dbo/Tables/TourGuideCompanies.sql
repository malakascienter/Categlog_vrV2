CREATE TABLE [dbo].[TourGuideCompanies] (
    [Id]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [Code]                  VARCHAR (20)   CONSTRAINT [DF_TourGuideCompanies_Code] DEFAULT ('') NOT NULL,
    [Description]           VARCHAR (100)  CONSTRAINT [DF_TourGuideCompanies_Description] DEFAULT ('') NOT NULL,
    [CommissionPercentage]  MONEY          CONSTRAINT [DF_TourGuideCompanies_CommissionPercentage] DEFAULT ((0)) NOT NULL,
    [ContactNo]             VARCHAR (15)   NOT NULL,
    [Email]                 VARCHAR (50)   NOT NULL,
    [IsActive]              BIT            CONSTRAINT [DF_TourGuideCompanies_IsActive] DEFAULT ((0)) NOT NULL,
    [IsDelete]              BIT            CONSTRAINT [DF_TourGuideCompanies_IsActive1_1] DEFAULT ((0)) NOT NULL,
    [PropertyId]            INT            CONSTRAINT [DF_TourGuideCompanies_IsActive1] DEFAULT ((0)) NOT NULL,
    [IsUpload]              BIT            CONSTRAINT [DF_TourGuideCompanies_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]         INT            NULL,
    [CreatedDateTime]       DATETIME       NULL,
    [LastModifiedUserID]    INT            NULL,
    [LastModifiedDateTime]  DATETIME       NULL,
    [Module]                VARCHAR (2)    CONSTRAINT [DF_TourGuideCompanies_Module] DEFAULT ('P') NULL,
    [BankName]              NVARCHAR (MAX) NULL,
    [BranchName]            NVARCHAR (MAX) NULL,
    [AccountNo]             NVARCHAR (MAX) NULL,
    [CompanyRegistrationNo] NVARCHAR (MAX) NULL,
    [IsApproved]            BIT            CONSTRAINT [DF_TourGuideCompanies_IsApproved] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TourGuideCompanies] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

