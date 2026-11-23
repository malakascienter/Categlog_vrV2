CREATE TABLE [dbo].[LTY_ValidationModeWisePromotion] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PromotionId]        INT             NOT NULL,
    [ValidationModeCode] VARCHAR (20)    NOT NULL,
    [FieldName]          VARCHAR (MAX)   NULL,
    [FieldValue]         VARCHAR (MAX)   NULL,
    [PromotionValue]     DECIMAL (18, 4) NULL,
    CONSTRAINT [PK_LTY_ValidationModeWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

