CREATE TABLE [dbo].[LTY_CouponMaster] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [DocumentNo]    VARCHAR (MAX)   NOT NULL,
    [PropertyId]    INT             NOT NULL,
    [Outlet]        VARCHAR (20)    NOT NULL,
    [IsPerecentage] BIT             NOT NULL,
    [Value]         DECIMAL (18, 4) NOT NULL,
    [ExpireDate]    DATETIME        NOT NULL,
    [CreateBy]      INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [MemberId]      INT             NULL,
    [Status]        VARCHAR (20)    CONSTRAINT [DF_LTY_CouponMaster_Status] DEFAULT ('ACTIVE') NULL,
    [ModifyBy]      INT             NULL,
    [ModifyDate]    DATETIME        NULL,
    [StatusReason]  NVARCHAR (300)  NULL,
    CONSTRAINT [PK_LTY_CouponMaster] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

