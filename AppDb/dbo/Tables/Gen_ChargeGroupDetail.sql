CREATE TABLE [dbo].[Gen_ChargeGroupDetail] (
    [ChargeDetailID]     INT             IDENTITY (1, 1) NOT NULL,
    [ChargeHeaderID]     INT             NOT NULL,
    [ChargeTypeID]       INT             NOT NULL,
    [ActualPercentage]   NUMERIC (18, 4) CONSTRAINT [DF_Gen_ChargeGroupDetail_ActualPercentage] DEFAULT ((0)) NOT NULL,
    [ChargeTypeSequence] INT             CONSTRAINT [DF_Gen_ChargeGroupDetail_ChargeTypeSequence] DEFAULT ((0)) NOT NULL,
    [IsActive]           BIT             NULL,
    [IsUpload]           BIT             CONSTRAINT [DF_Gen_ChargeGroupDetail_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]         INT             NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [ModifiedUserId]     INT             NULL,
    [ModifiedDateTime]   DATETIME        NULL,
    CONSTRAINT [PK_Gen_ChargeGroupDetail] PRIMARY KEY CLUSTERED ([ChargeDetailID] ASC)
);


GO

