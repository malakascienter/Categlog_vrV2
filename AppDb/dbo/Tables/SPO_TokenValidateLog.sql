CREATE TABLE [dbo].[SPO_TokenValidateLog] (
    [ID]                                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [UserName]                             VARCHAR (MAX)    NOT NULL,
    [TokenID]                              UNIQUEIDENTIFIER NOT NULL,
    [Sysdate]                              DATETIME         NOT NULL,
    [ExpairedDate]                         DATETIME         NOT NULL,
    [RefreshTokenID]                       UNIQUEIDENTIFIER NOT NULL,
    [RefreshTokenExpairedDate]             DATETIME         NOT NULL,
    [IsUsedRefreshTokenToGenarateNewToken] BIT              NULL,
    CONSTRAINT [PK_SPO_TokenValidateLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

