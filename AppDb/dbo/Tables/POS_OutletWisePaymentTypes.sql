CREATE TABLE [dbo].[POS_OutletWisePaymentTypes] (
    [PropertyId]      INT         NOT NULL,
    [PayCode]         VARCHAR (5) NOT NULL,
    [Outlet]          VARCHAR (5) NOT NULL,
    [IsUpload]        BIT         CONSTRAINT [DF_POS_OutletWisePaymentTypes_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT         NULL,
    [CreatedDateTime] DATETIME    NULL,
    [UpdatedUserId]   INT         NULL,
    [UpdatedDateTime] DATETIME    NULL
);


GO

