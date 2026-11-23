CREATE TABLE [dbo].[StockSpotApprovalLog] (
    [ID]                INT          IDENTITY (1, 1) NOT NULL,
    [StockSpotHeaderID] INT          NULL,
    [PropertyID]        INT          NULL,
    [LocationID]        INT          NULL,
    [DocNo]             VARCHAR (20) NULL,
    [SpotCheckDate]     DATETIME     NULL,
    [ApprovedDate]      DATETIME     NULL,
    [CreatedDate]       DATETIME     NULL,
    [RequestUserID]     INT          NULL,
    [ApprovedUserID]    INT          NULL,
    [Status]            VARCHAR (1)  NULL,
    [IsApproved]        BIT          NULL,
    [LevelNo]           INT          NULL
);


GO

