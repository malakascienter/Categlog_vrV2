CREATE TABLE [dbo].[sys_supp] (
    [SuppCode]       CHAR (5)      NOT NULL,
    [SuppName]       VARCHAR (50)  NOT NULL,
    [SuppAdd]        VARCHAR (120) NOT NULL,
    [SuppTel]        VARCHAR (15)  NOT NULL,
    [SuppTel1]       VARCHAR (15)  NOT NULL,
    [SuppTel2]       VARCHAR (15)  NOT NULL,
    [Email]          VARCHAR (30)  NOT NULL,
    [FaxNo]          VARCHAR (15)  NOT NULL,
    [AgentDetails]   VARCHAR (50)  NOT NULL,
    [MainSysCode]    CHAR (10)     NULL,
    [PurchaseCycle]  INT           NOT NULL,
    [withholdingvat] BIT           NOT NULL,
    [withholding]    BIT           NOT NULL,
    [percentage]     MONEY         NOT NULL,
    [Vatno]          VARCHAR (50)  NOT NULL,
    [TaxApplicable]  BIT           NOT NULL,
    [Nameonchq]      VARCHAR (60)  NOT NULL
);


GO

