CREATE TABLE [dbo].[WStations] (
    [Id]               INT          IDENTITY (1, 1) NOT NULL,
    [ComputerName]     VARCHAR (15) NULL,
    [IsDelete]         BIT          NULL,
    [IsUpload]         BIT          CONSTRAINT [DF_WStations_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]       INT          NULL,
    [CreatedUserId]    INT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [ModifiedUserId]   INT          NULL,
    [ModifiedDateTime] DATETIME     NULL,
    CONSTRAINT [PK_WStations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

