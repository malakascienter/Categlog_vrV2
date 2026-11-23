CREATE TABLE [dbo].[BatchLocationDetails] (
    [BatchLocationCode] VARCHAR (10) NOT NULL,
    [Outlet]            VARCHAR (5)  NOT NULL,
    [CreatedUserId]     INT          NULL,
    [CreatedDateTime]   DATETIME     NULL,
    [UpdateUserId]      INT          NULL,
    [UpdatedDateTime]   DATETIME     NULL,
    [PropertyId]        INT          NULL,
    [IsUpload]          BIT          CONSTRAINT [DF_BatchLocationDetails_IsUpload] DEFAULT ((0)) NOT NULL
);


GO

