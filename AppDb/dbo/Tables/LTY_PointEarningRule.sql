CREATE TABLE [dbo].[LTY_PointEarningRule] (
    [RuleId]         INT             IDENTITY (1, 1) NOT NULL,
    [RuleName]       NVARCHAR (MAX)  NOT NULL,
    [Description]    NVARCHAR (MAX)  NULL,
    [PropertyId]     INT             NOT NULL,
    [RuleTypeId]     INT             NOT NULL,
    [Rate]           DECIMAL (18, 4) NOT NULL,
    [BaseValueId]    INT             NOT NULL,
    [Multiplier]     DECIMAL (18, 4) NOT NULL,
    [IsActive]       BIT             CONSTRAINT [DF_LTY_PointEarningRule_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateBy]       INT             NOT NULL,
    [CreatedDate]    DATETIME        NOT NULL,
    [ModifyBy]       INT             NULL,
    [ModifyDate]     DATETIME        NULL,
    [ExpireDayCount] INT             CONSTRAINT [DF_LTY_PointEarningRule_ExpireDayCount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LTY_PointEarningRule] PRIMARY KEY CLUSTERED ([RuleId] ASC)
);


GO

