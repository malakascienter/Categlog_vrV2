CREATE TABLE [dbo].[TaxGroup_Details_History] (
    [ID]             BIGINT       NOT NULL,
    [SysDate]        DATETIME     CONSTRAINT [DF_TaxGroup_Details_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Code]           CHAR (3)     NOT NULL,
    [Description]    VARCHAR (50) NOT NULL,
    [TaxType]        VARCHAR (6)  CONSTRAINT [DF_TaxGroup_Details_History_TaxType] DEFAULT (getdate()) NOT NULL,
    [TaxTypeId]      INT          NULL,
    [Actual_Rate]    FLOAT (53)   NOT NULL,
    [Effective_Rate] FLOAT (53)   NOT NULL,
    [IsActive]       BIT          NULL,
    [CreatedUserId]  INT          NULL,
    [ModifiedUserId] INT          NULL,
    [CreatedDate]    DATETIME     NULL,
    [ModifiedDate]   DATETIME     NULL,
    [TaxGroupId]     INT          NULL,
    [PropertyId]     INT          NULL,
    [IsUpload]       BIT          NULL
);


GO

