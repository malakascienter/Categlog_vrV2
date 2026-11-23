CREATE TABLE [dbo].[BankwiseDeposit] (
    [DocNo]      BIGINT        CONSTRAINT [DF_BankwiseDeposit_DocNo] DEFAULT ((0)) NOT NULL,
    [TransDate]  DATETIME      NOT NULL,
    [BankCode]   VARCHAR (50)  NOT NULL,
    [DenoType]   VARCHAR (50)  NOT NULL,
    [DenoCount]  INT           CONSTRAINT [DF_BankwiseDeposit_DenoCount] DEFAULT ((0)) NOT NULL,
    [DenoName]   VARCHAR (50)  CONSTRAINT [DF_BankwiseDeposit_DenoName] DEFAULT ('') NOT NULL,
    [DenoAmount] MONEY         CONSTRAINT [DF_BankwiseDeposit_DenoAmount] DEFAULT ((0)) NOT NULL,
    [UserID]     VARCHAR (20)  CONSTRAINT [DF_BankwiseDeposit_UserID] DEFAULT ('') NOT NULL,
    [Remarks]    VARCHAR (250) CONSTRAINT [DF_BankwiseDeposit_Remarks] DEFAULT ('') NOT NULL,
    [OutletCode] VARCHAR (5)   CONSTRAINT [DF_BankwiseDeposit_OutletCode] DEFAULT ('') NOT NULL,
    [CCOrderNo]  VARCHAR (10)  CONSTRAINT [DF_BankwiseDeposit_CCOrderN0] DEFAULT ('') NOT NULL,
    [isUpload]   BIT           CONSTRAINT [DF_BankwiseDeposit_isUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId] INT           NOT NULL,
    [AccDocNo]   AS            (right(([OutletCode]+'0')+CONVERT([varchar](8),[DOCNO]),(8)))
);


GO

