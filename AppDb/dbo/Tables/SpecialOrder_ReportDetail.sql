CREATE TABLE [dbo].[SpecialOrder_ReportDetail] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [ReportCode]  NVARCHAR (150) NULL,
    [DisplayName] NVARCHAR (150) NULL,
    [ReportName]  NVARCHAR (250) NULL,
    [ReportURL]   VARCHAR (500)  NULL,
    [Active]      BIT            NULL,
    [Parameter]   NVARCHAR (MAX) NULL
);


GO

