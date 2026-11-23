CREATE TABLE [dbo].[LTY_Tier] (
    [TierId]            INT             IDENTITY (1, 1) NOT NULL,
    [TierName]          VARCHAR (MAX)   NOT NULL,
    [PropertyId]        INT             NOT NULL,
    [MiniumPoint]       DECIMAL (18, 4) NOT NULL,
    [MaxiumPoint]       DECIMAL (18, 4) NOT NULL,
    [RuleId]            INT             NOT NULL,
    [SortOrder]         INT             NOT NULL,
    [IsActive]          BIT             CONSTRAINT [DF_LTY_Tier_IsActive] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         INT             NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [ModifyId]          INT             NULL,
    [ModifyDate]        DATETIME        NULL,
    [IsTierAutoUpgrade] BIT             CONSTRAINT [DF_LTY_Tier_IsTierAutoUpgrade] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LTY_Tier] PRIMARY KEY CLUSTERED ([TierId] ASC)
);


GO

