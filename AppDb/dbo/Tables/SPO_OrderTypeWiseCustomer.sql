CREATE TABLE [dbo].[SPO_OrderTypeWiseCustomer] (
    [ID]                BIGINT IDENTITY (1, 1) NOT NULL,
    [CustomerTypeID]    BIGINT NOT NULL,
    [OrderTypeID]       BIGINT NOT NULL,
    [PriceTypeID]       BIGINT CONSTRAINT [DF_SPO_OrderTypeWiseCustomer_PriceTypeID] DEFAULT ((0)) NOT NULL,
    [IsNeedApproval]    BIT    CONSTRAINT [DF_SPO_OrderTypeWiseCustomer_IsNeedApproval] DEFAULT ((0)) NOT NULL,
    [IsAllowCredit]     BIT    CONSTRAINT [DF_Table_1_IsNeedApproval1] DEFAULT ((0)) NOT NULL,
    [IsOutletWisePrice] BIT    CONSTRAINT [DF_SPO_OrderTypeWiseCustomer_IsOutletWisePrice] DEFAULT ((0)) NOT NULL
);


GO

