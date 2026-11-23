CREATE TABLE [dbo].[EventHeader] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [EventNo]          VARCHAR (50)   NOT NULL,
    [EventName]        NVARCHAR (200) NOT NULL,
    [CreateDate]       DATETIME       NOT NULL,
    [CreateUser]       NVARCHAR (100) NOT NULL,
    [LastModifiedDate] DATETIME       NOT NULL,
    [LastModifiedUser] NVARCHAR (100) NOT NULL,
    [Address]          NVARCHAR (500) NOT NULL,
    [CoverBinary]      IMAGE          NOT NULL,
    [ThubnailBinary]   IMAGE          NOT NULL,
    [CoverPath]        VARCHAR (500)  NOT NULL,
    [ThubnailPath]     VARCHAR (500)  NULL,
    [Remark]           VARCHAR (200)  CONSTRAINT [DF_EventHeader_Remark] DEFAULT ('') NOT NULL,
    [OutletCode]       VARCHAR (5)    CONSTRAINT [DF_EventHeader_OutletCode] DEFAULT ('') NOT NULL,
    [PropertyId]       INT            CONSTRAINT [DF_EventHeader_PropertyId] DEFAULT ((0)) NOT NULL,
    [IsEventAvailable] BIT            CONSTRAINT [DF_EventHeader_IsEventAvailable] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_EventHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

