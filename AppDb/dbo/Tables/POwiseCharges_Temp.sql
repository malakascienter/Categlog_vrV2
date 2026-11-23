CREATE TABLE [dbo].[POwiseCharges_Temp] (
    [POwiseChangesID]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [POHeaderID]         BIGINT          NOT NULL,
    [AdditionalChargeID] BIGINT          NOT NULL,
    [ChargeAmount]       DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.POwiseCharges_Temp] PRIMARY KEY CLUSTERED ([POwiseChangesID] ASC)
);


GO

