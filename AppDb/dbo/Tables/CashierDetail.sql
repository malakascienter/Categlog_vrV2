CREATE TABLE [dbo].[CashierDetail] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [CashierHeaderID]        INT           NULL,
    [UserID]                 INT           NULL,
    [DTypeID]                INT           NULL,
    [Nos]                    INT           NULL,
    [Value]                  MONEY         NULL,
    [SysDate]                DATETIME      NULL,
    [PropertyID]             INT           NULL,
    [LocationID]             INT           NULL,
    [SystemAmout]            MONEY         NULL,
    [BussinessDate]          DATETIME      NULL,
    [IsFirstApproval]        BIT           NULL,
    [IsSecondApproval]       BIT           NULL,
    [FirstApprovalRemark]    VARCHAR (200) NULL,
    [SecondApprovalRemark]   VARCHAR (200) NULL,
    [FirstApprovalUser]      INT           NULL,
    [FirstApprovalDateTime]  DATETIME      NULL,
    [SecondApprovalUser]     INT           NULL,
    [SecondApprovalDateTime] DATETIME      NULL
);


GO

