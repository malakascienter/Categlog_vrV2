CREATE TABLE [dbo].[TokenValidateLog] (
    [ID]                                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [UserName]                             VARCHAR (50)     NOT NULL,
    [TokenID]                              UNIQUEIDENTIFIER NOT NULL,
    [Sysdate]                              DATETIME         CONSTRAINT [DF_TokenValidateLog_Sysdate] DEFAULT (getdate()) NOT NULL,
    [ExpairedDate]                         DATETIME         CONSTRAINT [DF_TokenValidateLog_IsExpaired] DEFAULT ((0)) NOT NULL,
    [RefreshTokenID]                       UNIQUEIDENTIFIER NOT NULL,
    [RefreshTokenExpairedDate]             DATETIME         NOT NULL,
    [IsUsedRefreshTokenToGenarateNewToken] BIT              DEFAULT ((0)) NOT NULL
);


GO

