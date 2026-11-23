CREATE TABLE [dbo].[DayEnd_Validation_Settings] (
    [ID]                    INT      IDENTITY (1, 1) NOT NULL,
    [CompanyID]             INT      NULL,
    [IsResturant]           BIT      NULL,
    [IsRetail]              BIT      NULL,
    [DayEndModuleID]        INT      NULL,
    [ValidationProcessCode] CHAR (1) NULL,
    [IsReconMandatory]      BIT      CONSTRAINT [DF_DayEnd_Validation_Settings_IsReconMandatory] DEFAULT ((0)) NULL
);


GO

