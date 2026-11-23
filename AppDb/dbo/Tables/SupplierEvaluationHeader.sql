CREATE TABLE [dbo].[SupplierEvaluationHeader] (
    [ID]                          INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]                  INT             NULL,
    [SupplierID]                  INT             NULL,
    [EvaluationTemplateID]        INT             NULL,
    [TotalScore]                  DECIMAL (18, 2) NULL,
    [CreatedUserId]               INT             NULL,
    [CreatedDate]                 DATETIME        CONSTRAINT [DF_SupplierGradingHeader_CreatedDate] DEFAULT (getdate()) NULL,
    [DocumentNumber]              NVARCHAR (40)   NULL,
    [IsApproved]                  BIT             CONSTRAINT [DF_SupplierEvaluationHeader_IsApproved] DEFAULT ((0)) NOT NULL,
    [DocumentStatus]              NVARCHAR (2)    CONSTRAINT [DF_SupplierEvaluationHeader_DocumentStatus] DEFAULT ('P') NOT NULL,
    [SupplierGrade]               NVARCHAR (10)   NULL,
    [IsBlackListedApproved]       BIT             NULL,
    [GradePercentage]             DECIMAL (9, 2)  NULL,
    [BenchMarkFailedGRNs]         INT             NULL,
    [OriginalTotalScore]          DECIMAL (18, 2) NULL,
    [OriginalSupplierGrade]       NVARCHAR (10)   NULL,
    [OriginalGradePercentage]     DECIMAL (9, 2)  NULL,
    [OriginalBenchMarkFailedGRNs] INT             NULL,
    [BlackListApprovedUserID]     INT             NULL,
    [BlackListApprovedDate]       DATETIME        NULL,
    [BlackListApprovedRemarks]    NVARCHAR (500)  NULL,
    [BlackListOriginalGrade]      NVARCHAR (10)   NULL
);


GO

