CREATE TABLE [dbo].[LTY_Member] (
    [MemberId]          INT           IDENTITY (1, 1) NOT NULL,
    [MembershipCode]    VARCHAR (20)  NOT NULL,
    [PropertyId]        INT           NOT NULL,
    [Salutation]        NVARCHAR (8)  NOT NULL,
    [FirstName]         VARCHAR (MAX) NOT NULL,
    [LastName]          VARCHAR (MAX) NOT NULL,
    [Email]             VARCHAR (MAX) NOT NULL,
    [PrimaryMobileNo]   VARCHAR (50)  NOT NULL,
    [SecondaryMobileNo] VARCHAR (50)  NOT NULL,
    [Address]           VARCHAR (MAX) NULL,
    [IsActive]          BIT           CONSTRAINT [DF_LTY_Member_IsActive] DEFAULT ((0)) NOT NULL,
    [RegisterOutlet]    VARCHAR (20)  NOT NULL,
    [TierId]            INT           NULL,
    [CreatedBy]         INT           NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifyBy]          INT           NULL,
    [ModifyDate]        DATETIME      NULL,
    [BirthDay]          DATETIME      CONSTRAINT [DF_LTY_Member_BirthDay] DEFAULT ((0)) NOT NULL,
    [TimeZoneId]        VARCHAR (64)  NULL,
    CONSTRAINT [PK_LTY_Member] PRIMARY KEY CLUSTERED ([MemberId] ASC)
);


GO

