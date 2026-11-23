CREATE TABLE [dbo].[Locations] (
    [Id]                                  INT            IDENTITY (1, 1) NOT NULL,
    [CompanyID]                           INT            NOT NULL,
    [Code]                                NVARCHAR (MAX) NULL,
    [Name]                                NVARCHAR (MAX) NULL,
    [IsActive]                            BIT            NOT NULL,
    [IPAddress]                           NVARCHAR (MAX) NULL,
    [CreatedUserID]                       INT            NOT NULL,
    [LastModUserID]                       INT            NOT NULL,
    [CreatedDate]                         DATETIME       NOT NULL,
    [LastModDate]                         DATETIME       NOT NULL,
    [LocationType]                        NVARCHAR (MAX) NULL,
    [Prefix]                              NVARCHAR (MAX) NULL,
    [PropertyId]                          INT            NULL,
    [DefaultLocation]                     BIT            CONSTRAINT [DF__Locations__Defau__1B48FEF0] DEFAULT ((0)) NULL,
    [DailyMarketDepartment]               INT            NULL,
    [ApplyDailyMarketProcess]             BIT            CONSTRAINT [DF_Locations_ApplyDailyMarketProcess] DEFAULT ((0)) NULL,
    [GroupName]                           NVARCHAR (10)  NULL,
    [IsMainStore]                         BIT            CONSTRAINT [DF_Locations_IsMainStore] DEFAULT ((0)) NULL,
    [CurrentDate]                         DATE           NULL,
    [IsSalesLocation]                     BIT            CONSTRAINT [DF_Locations_IsSalesLocation] DEFAULT ((0)) NULL,
    [DepartmentID]                        BIGINT         DEFAULT ((0)) NOT NULL,
    [DeliveryAddress]                     VARCHAR (MAX)  NULL,
    [ContactPerson]                       VARCHAR (MAX)  NULL,
    [FirstEmail]                          VARCHAR (MAX)  NULL,
    [SecondEmail]                         VARCHAR (MAX)  NULL,
    [TelNo]                               VARCHAR (MAX)  NULL,
    [IsProductionLocation]                BIT            DEFAULT ((0)) NULL,
    [IsGLEnabled]                         BIT            CONSTRAINT [DF_Locations_IsGLEnabled] DEFAULT ((1)) NOT NULL,
    [IsReconBackDateEnable]               BIT            CONSTRAINT [DF_Locations_IsReconBackDateEnable] DEFAULT ((1)) NOT NULL,
    [IsReconMandatory]                    BIT            DEFAULT ((0)) NOT NULL,
    [IsOnlyOneReconPerDay]                BIT            DEFAULT ((0)) NOT NULL,
    [BackdateDayCountWhenBackDateDisable] INT            DEFAULT ((0)) NOT NULL,
    [IsFranchise]                         BIT            CONSTRAINT [DF_Locations_IsFranchise] DEFAULT ((0)) NULL,
    [DayEndValidationMode]                CHAR (4)       NULL,
    [IsMinusStockValidate]                BIT            CONSTRAINT [DF_Locations_IsMinusStockValidate] DEFAULT ((0)) NULL,
    [IsQuantityExceed]                    BIT            CONSTRAINT [DF_Locations_IsQuantityExceed] DEFAULT ((0)) NOT NULL,
    [Is_Inv_DayEndValidationSkip]         BIT            CONSTRAINT [DF_Locations_Is_Inv_DayEndValidationSkip] DEFAULT ((0)) NULL,
    [DayEndItemTempId]                    INT            CONSTRAINT [DF_Locations_DayEndItemTempId] DEFAULT ((0)) NOT NULL,
    [IsAutoDayEndEnable]                  BIT            CONSTRAINT [DF_Locations_IsAutoDayEndEnable] DEFAULT ((0)) NULL,
    [IsDistrict]                          BIT            CONSTRAINT [DF_Locations_IsDistrict] DEFAULT ((0)) NULL,
    [ProviceID]                           INT            CONSTRAINT [DF_Locations_ProviceID] DEFAULT ((0)) NULL,
    [DistrictID]                          INT            CONSTRAINT [DF_Locations_DistrictID] DEFAULT ((0)) NULL,
    [IsInvoiceLocation]                   BIT            DEFAULT ((0)) NOT NULL,
    [IsInvoice]                           BIT            CONSTRAINT [DF_Locations_IsInvoice] DEFAULT ((0)) NULL,
    [FranchiseDepartmentID]               INT            NULL,
    [HoldingDays]                         INT            CONSTRAINT [DF_Locations_HoldingDays] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_Locations_IsMainStore]
    ON [dbo].[Locations]([IsMainStore] ASC) WHERE ([IsMainStore]=(1));


GO

CREATE NONCLUSTERED INDEX [IDX_Locations_ID]
    ON [dbo].[Locations]([Id] ASC);


GO

