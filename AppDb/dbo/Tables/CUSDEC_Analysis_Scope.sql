CREATE TABLE [dbo].[CUSDEC_Analysis_Scope] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (MAX) NULL,
    [Type]              CHAR (2)       NULL,
    [IsActive]          BIT            NULL,
    [ParamItem]         BIT            NULL,
    [ParamSupplier]     BIT            NULL,
    [ParamProvince]     BIT            NULL,
    [ParamDistrict]     BIT            NULL,
    [ParamDS]           BIT            NULL,
    [ParamGN]           BIT            NULL,
    [ParamFromDate]     BIT            NULL,
    [ParamToDate]       BIT            NULL,
    [ReportName]        NVARCHAR (MAX) NULL,
    [ReportDisplayName] NVARCHAR (MAX) NULL
);


GO

