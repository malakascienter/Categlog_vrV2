CREATE TABLE [dbo].[TaxGroup_Details] (
    [ID]             BIGINT       IDENTITY (1, 1) NOT NULL,
    [Code]           CHAR (3)     CONSTRAINT [DF_TaxGroup_Ref_Code] DEFAULT (' ') NOT NULL,
    [Description]    VARCHAR (50) CONSTRAINT [DF_TaxGroup_Ref_Description] DEFAULT (' ') NOT NULL,
    [TaxType]        VARCHAR (6)  CONSTRAINT [DF_TaxGroup_Ref_TaxType] DEFAULT ((0)) NOT NULL,
    [TaxTypeId]      INT          NULL,
    [Actual_Rate]    FLOAT (53)   CONSTRAINT [DF_Table_1_Rate] DEFAULT ((0)) NOT NULL,
    [Effective_Rate] FLOAT (53)   CONSTRAINT [DF_TaxGroup_Ref_Effective_Rate] DEFAULT ((0)) NOT NULL,
    [IsActive]       BIT          NULL,
    [CreatedUserId]  INT          NULL,
    [ModifiedUserId] INT          NULL,
    [CreatedDate]    DATETIME     NULL,
    [ModifiedDate]   DATETIME     NULL,
    [TaxGroupId]     INT          NULL
);


GO

