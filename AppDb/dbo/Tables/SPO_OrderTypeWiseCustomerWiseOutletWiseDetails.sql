CREATE TABLE [dbo].[SPO_OrderTypeWiseCustomerWiseOutletWiseDetails] (
    [ID]             BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerTypeID] BIGINT       DEFAULT ((0)) NOT NULL,
    [OrderTypeID]    BIGINT       DEFAULT ((0)) NOT NULL,
    [OutletCode]     VARCHAR (10) DEFAULT ('') NOT NULL,
    [PriceTypeID]    BIGINT       DEFAULT ((0)) NOT NULL
);


GO

