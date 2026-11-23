CREATE TABLE [dbo].[ProcurementRequest] (
    [ID]                         INT             IDENTITY (1, 1) NOT NULL,
    [CompanyID]                  INT             NULL,
    [LocationID]                 INT             NULL,
    [DocumentNo]                 VARCHAR (MAX)   NULL,
    [InitiatedDate]              DATETIME        NULL,
    [StatusID]                   INT             NULL,
    [GeneralDescription]         VARCHAR (MAX)   NULL,
    [EvaluationCriteriaID]       INT             NULL,
    [NewItem]                    BIT             NULL,
    [ItemID]                     INT             NULL,
    [ItemName]                   VARCHAR (MAX)   NULL,
    [UnitID]                     INT             NULL,
    [Quantity]                   DECIMAL (18, 8) NULL,
    [IsApprove]                  BIT             CONSTRAINT [DF_ProcurementRequest_IsApprove] DEFAULT ((0)) NOT NULL,
    [UserID]                     INT             NULL,
    [UserProfileId]              INT             NULL,
    [ApproveLevelID]             INT             NULL,
    [SeqID]                      INT             NULL,
    [XMLRequestItem]             XML             NULL,
    [StockItemRequestID]         INT             NULL,
    [IsMultipleSupplierRequired] BIT             CONSTRAINT [DF_ProcurementRequest_IsMultipleSupplierRequired] DEFAULT ((0)) NULL,
    [StockItemHeaderID]          INT             CONSTRAINT [DF_ProcurementRequest_StockItemHeaderID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__Procurem__3214EC27B0282EC5] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

