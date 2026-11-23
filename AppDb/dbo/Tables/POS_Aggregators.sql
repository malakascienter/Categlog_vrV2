CREATE TABLE [dbo].[POS_Aggregators] (
    [AutoId]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ID]                       TINYINT         CONSTRAINT [DF__POS_Aggregat__ID__4FA3F1AD] DEFAULT ((0)) NOT NULL,
    [Aggregator]               VARCHAR (50)    NOT NULL,
    [AddPercentage]            NUMERIC (18, 2) CONSTRAINT [DF__POS_Aggre__AddPe__509815E6] DEFAULT ((0)) NOT NULL,
    [PayType]                  VARCHAR (2)     CONSTRAINT [DF__POS_Aggre__PayTy__518C3A1F] DEFAULT ('') NOT NULL,
    [Active]                   BIT             CONSTRAINT [DF__POS_Aggre__Activ__52805E58] DEFAULT ((0)) NOT NULL,
    [SortOrder]                TINYINT         CONSTRAINT [DF__POS_Aggre__SortO__53748291] DEFAULT ((0)) NOT NULL,
    [PriceTypeID]              INT             CONSTRAINT [DF_POS_Aggregators_PriceTypeID] DEFAULT ((0)) NOT NULL,
    [AggregatorChargeHeaderID] INT             CONSTRAINT [DF_POS_Aggregators_ChargeHeaderID] DEFAULT ((0)) NOT NULL,
    [ButtonColour]             VARCHAR (9)     CONSTRAINT [DF_POS_Aggregators_ButtonColour] DEFAULT ((0)) NOT NULL,
    [PropertyId]               INT             CONSTRAINT [DF__POS_Aggre__Prope__57451375] DEFAULT ((0)) NOT NULL,
    [IsIntegrate]              BIT             CONSTRAINT [DF__POS_Aggre__IsInt__66875705] DEFAULT ((0)) NOT NULL
);


GO

