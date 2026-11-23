CREATE TABLE [dbo].[Log_SMS_OTP] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Request]  VARCHAR (MAX) NULL,
    [Response] VARCHAR (MAX) NULL,
    [MobileNo] NCHAR (20)    NULL,
    [IsSent]   BIT           NULL,
    [IsFail]   BIT           NULL,
    [SysDate]  DATETIME      CONSTRAINT [DF_Log_SMS_OTP_SysDate] DEFAULT (getdate()) NULL,
    [TextOTP]  VARCHAR (100) NULL
);


GO

