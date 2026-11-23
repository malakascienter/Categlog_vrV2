CREATE TABLE [dbo].[Location] (
    [Code]              CHAR (3)      NULL,
    [Description]       VARCHAR (30)  NULL,
    [Active]            BIT           CONSTRAINT [DF_Location_Active] DEFAULT ((1)) NOT NULL,
    [IPAddress]         VARCHAR (50)  NULL,
    [UpdateGL]          BIT           DEFAULT ((1)) NOT NULL,
    [Outlet]            VARCHAR (5)   CONSTRAINT [DF_Location_Outlet] DEFAULT ('') NOT NULL,
    [OrgID]             INT           DEFAULT ((246)) NOT NULL,
    [stockAccount]      VARCHAR (250) DEFAULT ('SRT.10SRT1040.SRT0101.000000000.12010101.000000.000.SRT.000') NOT NULL,
    [location_Add_Code] VARCHAR (250) NULL,
    [LOB_Code]          VARCHAR (250) NULL,
    [Address]           VARCHAR (250) CONSTRAINT [DF_Location_Address] DEFAULT ('') NOT NULL,
    [TelNo]             VARCHAR (50)  CONSTRAINT [DF_Location_Address1] DEFAULT ('') NOT NULL,
    [Fax]               VARCHAR (50)  CONSTRAINT [DF_Location_TelNo1] DEFAULT ('') NOT NULL,
    [Email]             VARCHAR (50)  CONSTRAINT [DF_Location_Fax1] DEFAULT ('') NOT NULL,
    [PropertyId]        INT           NULL
);


GO

