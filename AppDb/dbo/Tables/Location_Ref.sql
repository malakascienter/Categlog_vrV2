CREATE TABLE [dbo].[Location_Ref] (
    [code]                           CHAR (3)      NOT NULL,
    [description]                    VARCHAR (30)  CONSTRAINT [DF_Location_Ref_description] DEFAULT (' ') NOT NULL,
    [NextNo]                         INT           CONSTRAINT [DF_Location_Ref_NextNo] DEFAULT ((1)) NOT NULL,
    [ID]                             CHAR (1)      NULL,
    [RoomService]                    BIT           CONSTRAINT [DF_Location_Ref_RoomService_1] DEFAULT ((0)) NOT NULL,
    [BevAccCode]                     CHAR (12)     CONSTRAINT [DF_Location_Ref_BevAccCode] DEFAULT (' ') NOT NULL,
    [FoodAccCode]                    CHAR (12)     CONSTRAINT [DF_Location_Ref_FoodAccCode] DEFAULT (' ') NOT NULL,
    [TobacooAccCode]                 CHAR (12)     CONSTRAINT [DF_Location_Ref_TobacooAccCode] DEFAULT (' ') NOT NULL,
    [LiquorAccCode]                  CHAR (12)     CONSTRAINT [DF_Location_Ref_LiquorAccCode] DEFAULT (' ') NOT NULL,
    [OtherAccCode]                   CHAR (12)     CONSTRAINT [DF_Location_Ref_OtherAccCode] DEFAULT (' ') NOT NULL,
    [DeptCode]                       CHAR (3)      CONSTRAINT [DF_Location_Ref_DeptCode] DEFAULT ('CO') NOT NULL,
    [SerChgVal]                      MONEY         CONSTRAINT [DF_Location_Ref_SerChgVal] DEFAULT ((10)) NOT NULL,
    [WineAccCode]                    CHAR (12)     CONSTRAINT [DF_Location_Ref_WineAccCode] DEFAULT (' ') NOT NULL,
    [CostBevAccCode]                 CHAR (12)     CONSTRAINT [DF_Location_Ref_CostBevAccCode] DEFAULT (' ') NOT NULL,
    [CostFoodAccCode]                CHAR (12)     CONSTRAINT [DF_Location_Ref_CostFoodAccCode] DEFAULT (' ') NOT NULL,
    [CostTobacooAccCode]             CHAR (12)     CONSTRAINT [DF_Location_Ref_CostTobacooAccCode] DEFAULT (' ') NOT NULL,
    [CostLiquorAccCode]              CHAR (12)     CONSTRAINT [DF_Location_Ref_CostLiquorAccCode] DEFAULT (' ') NOT NULL,
    [CostOtherAccCode]               CHAR (12)     CONSTRAINT [DF_Location_Ref_CostOtherAccCode] DEFAULT (' ') NOT NULL,
    [CostWineAcccode]                CHAR (12)     CONSTRAINT [DF_Location_Ref_CostWineAcccode] DEFAULT (' ') NOT NULL,
    [KOTLoc]                         CHAR (3)      CONSTRAINT [DF_Location_Ref_KOTLoc] DEFAULT ('MAK') NOT NULL,
    [BOTLoc]                         CHAR (3)      CONSTRAINT [DF_Location_Ref_BOTLoc] DEFAULT (' ') NOT NULL,
    [Active]                         BIT           CONSTRAINT [DF_Location_Ref_Active] DEFAULT ((1)) NOT NULL,
    [CPU]                            BIT           CONSTRAINT [DF_Location_Ref_CPU_1] DEFAULT ((0)) NOT NULL,
    [IPAddress]                      VARCHAR (50)  NULL,
    [Kitchen_Code]                   CHAR (3)      CONSTRAINT [DF_Location_Ref_Kitchen_Code] DEFAULT ('') NOT NULL,
    [FGLoc]                          CHAR (3)      CONSTRAINT [DF_Location_Ref_FGLoc] DEFAULT ('') NOT NULL,
    [StoreID]                        INT           CONSTRAINT [DF_Location_Ref_StoreID] DEFAULT ((0)) NOT NULL,
    [IPAddressALT]                   VARCHAR (50)  NULL,
    [ORGID]                          INT           DEFAULT ((246)) NOT NULL,
    [TakeoutSalesAccCode]            VARCHAR (250) DEFAULT ('SRT.20SRT7300.SRT0101.SRT010101.12010201.000005.000.SRT.000') NOT NULL,
    [DeliverySalesAccCode]           VARCHAR (250) DEFAULT ('SRT.20SRT7300.SRT0101.SRT010101.12010201.000005.000.SRT.000') NOT NULL,
    [DriveThroSalesAccCode]          VARCHAR (250) DEFAULT ('SRT.20SRT7300.SRT0101.SRT010101.12010201.000005.000.SRT.000') NOT NULL,
    [DriveInSalesAccCode]            VARCHAR (250) DEFAULT ('SRT.20SRT7300.SRT0101.SRT010101.12010201.000005.000.SRT.000') NOT NULL,
    [PartySalesAccCode]              VARCHAR (250) DEFAULT ('SRT.20SRT7300.SRT0101.SRT010101.12010201.000005.000.SRT.000') NOT NULL,
    [SalesAccCode]                   VARCHAR (250) NULL,
    [location_Add_Code]              VARCHAR (50)  NULL,
    [LOB_Code]                       VARCHAR (50)  NULL,
    [AdvanceAccCode]                 VARCHAR (250) NULL,
    [DashboardDisplayOrder]          INT           CONSTRAINT [DF_Location_Ref_DashboardDisplayOrder] DEFAULT ((10)) NOT NULL,
    [PropertyId]                     INT           NULL,
    [StockLocationID]                INT           CONSTRAINT [DF_Location_Ref_LocationID] DEFAULT ((0)) NOT NULL,
    [DepartmentID]                   INT           CONSTRAINT [DF_Location_Ref_DepartmentID] DEFAULT ((0)) NOT NULL,
    [IsDefault]                      BIT           DEFAULT ((0)) NOT NULL,
    [OutletServer]                   VARCHAR (500) DEFAULT ('') NOT NULL,
    [OutletDatabase]                 VARCHAR (500) DEFAULT ('') NOT NULL,
    [OutletServerUsername]           VARCHAR (500) DEFAULT ('') NOT NULL,
    [OutletServerPassword]           VARCHAR (500) DEFAULT ('') NOT NULL,
    [CurrentDate]                    DATETIME      DEFAULT (getdate()) NOT NULL,
    [RefCode]                        VARCHAR (10)  DEFAULT ('') NOT NULL,
    [RefName]                        VARCHAR (30)  DEFAULT ('') NOT NULL,
    [StalllCode]                     VARCHAR (10)  DEFAULT ('') NOT NULL,
    [StallName]                      VARCHAR (50)  DEFAULT ('') NOT NULL,
    [UberEatStoresURL]               VARCHAR (MAX) DEFAULT ('') NOT NULL,
    [UberEatclient_id]               VARCHAR (MAX) DEFAULT ('') NOT NULL,
    [UberEatclient_secret]           VARCHAR (MAX) DEFAULT ('') NOT NULL,
    [UberEatAggregatorType]          INT           DEFAULT ((0)) NOT NULL,
    [DefaultPriceTypeId]             INT           DEFAULT ((0)) NOT NULL,
    [UberEat_StoreId]                VARCHAR (500) DEFAULT ('') NOT NULL,
    [UberEat_ChannelCode]            VARCHAR (5)   DEFAULT ('') NOT NULL,
    [OutletColorCode]                VARCHAR (200) DEFAULT ('#85C1E9') NOT NULL,
    [IsForeignCurrency]              BIT           DEFAULT ((0)) NOT NULL,
    [IsGLEnabled]                    BIT           DEFAULT ((1)) NOT NULL,
    [BaseCurrencyCode]               VARCHAR (50)  DEFAULT ('LKR') NOT NULL,
    [BadaginiApiKey]                 VARCHAR (MAX) DEFAULT ('') NOT NULL,
    [DefaultScanDineShowPriceTypeId] INT           DEFAULT ((0)) NOT NULL,
    [PickMe_ApiKey]                  VARCHAR (500) NULL,
    [Maalu_StoreId]                  VARCHAR (200) NULL,
    [IsHOBreakTax]                   BIT           CONSTRAINT [DF_Location_Ref_IsHOBreakTax] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Location_Ref] PRIMARY KEY CLUSTERED ([code] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IDX_Location_Ref_Code_PropertyId]
    ON [dbo].[Location_Ref]([code] ASC, [PropertyId] ASC)
    INCLUDE([StockLocationID], [description]);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_Location_Ref_Maalu_StoreId]
    ON [dbo].[Location_Ref]([Maalu_StoreId] ASC) WHERE ([Maalu_StoreId] IS NOT NULL);


GO

