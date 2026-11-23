CREATE TABLE [dbo].[POwiseCharges] (
    [POwiseChangesID]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [POHeaderID]         BIGINT          NOT NULL,
    [AdditionalChargeID] BIGINT          NOT NULL,
    [ChargeAmount]       DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.POwiseCharges] PRIMARY KEY CLUSTERED ([POwiseChangesID] ASC)
);


GO

