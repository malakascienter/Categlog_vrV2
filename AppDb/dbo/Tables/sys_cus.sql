CREATE TABLE [dbo].[sys_cus] (
    [Code]       CHAR (5)      NOT NULL,
    [Name]       VARCHAR (50)  NOT NULL,
    [Address]    VARCHAR (120) NOT NULL,
    [Tel]        VARCHAR (15)  NOT NULL,
    [Email]      VARCHAR (30)  NOT NULL,
    [ConPer]     VARCHAR (30)  NOT NULL,
    [Fax]        VARCHAR (15)  NOT NULL,
    [CrLimit]    MONEY         NOT NULL,
    [CrBal]      MONEY         NOT NULL,
    [Discount]   MONEY         NOT NULL,
    [TaxApp]     BIT           NOT NULL,
    [ServiceApp] BIT           NOT NULL,
    [CustType]   CHAR (1)      NOT NULL,
    [vatno]      CHAR (50)     NULL
);


GO

