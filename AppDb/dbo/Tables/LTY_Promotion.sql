CREATE TABLE [dbo].[LTY_Promotion] (
    [PromotionId]          INT             IDENTITY (1, 1) NOT NULL,
    [PromotionName]        NVARCHAR (MAX)  NOT NULL,
    [Description]          VARCHAR (MAX)   NOT NULL,
    [PropertyId]           INT             NOT NULL,
    [StartDate]            DATE            NOT NULL,
    [EndDate]              DATE            NOT NULL,
    [StartTime]            TIME (7)        NOT NULL,
    [EndTime]              TIME (7)        NOT NULL,
    [IsActive]             BIT             CONSTRAINT [DF_LTY_Promotion_IsActive] DEFAULT ((0)) NOT NULL,
    [MinBillAmount]        DECIMAL (18, 4) NOT NULL,
    [IsDiscountPercentage] BIT             NULL,
    [Discount]             DECIMAL (18, 4) NULL,
    [CreatedBy]            INT             NOT NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [ModifyBy]             INT             NULL,
    [ModifyDate]           DATETIME        NULL,
    [MaxBillAmount]        DECIMAL (18, 4) CONSTRAINT [DF_LTY_Promotion_MaxBillAmount] DEFAULT ((0)) NOT NULL,
    [IsUploadImage]        BIT             CONSTRAINT [DF_LTY_Promotion_IsUploadImage] DEFAULT ((0)) NOT NULL,
    [ImageURL]             NVARCHAR (MAX)  NULL,
    [IsBirthdayDate]       BIT             CONSTRAINT [DF_LTY_Promotion_IsBirthdayDate] DEFAULT ((0)) NOT NULL,
    [IsBirthdayMonth]      BIT             CONSTRAINT [DF_LTY_Promotion_IsBirthdayMonth] DEFAULT ((0)) NOT NULL,
    [IsNewMember]          BIT             NULL,
    [NewMemberDayCount]    INT             NULL,
    CONSTRAINT [PK_LTY_Promotion] PRIMARY KEY CLUSTERED ([PromotionId] ASC)
);


GO

