CREATE TABLE [dbo].[ReOrderLocationWiseEmail] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [LocationID]        INT            NULL,
    [CompanyID]         INT            NULL,
    [EmailList]         NVARCHAR (MAX) NULL,
    [LastSentDate]      DATETIME       NULL,
    [LastSentStatus]    CHAR (3)       NULL,
    [LastDocNo]         NVARCHAR (300) NULL,
    [IsActive]          BIT            CONSTRAINT [DF_ReOrderLocationWiseEmail_IsActive] DEFAULT ((1)) NOT NULL,
    [LastSentHotelDate] DATE           NULL
);


GO

