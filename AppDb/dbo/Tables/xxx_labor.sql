CREATE TABLE [dbo].[xxx_labor] (
    [LaborMasterID]  INT             NOT NULL,
    [LaborTypeId]    INT             NOT NULL,
    [LabourTypeCode] NVARCHAR (MAX)  NULL,
    [LabourTypeName] NVARCHAR (MAX)  NULL,
    [LaborUnitId]    INT             NOT NULL,
    [LaborUnitName]  NVARCHAR (MAX)  NULL,
    [Price]          DECIMAL (18, 2) NOT NULL
);


GO

