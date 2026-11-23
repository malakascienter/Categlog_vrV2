CREATE TABLE [dbo].[POS_Settings] (
    [CheckQuantity] BIT CONSTRAINT [DF_POS_Settings_CheckQuantity] DEFAULT ((1)) NOT NULL
);


GO

