CREATE TABLE [dbo].[AutoDayEnd_Completed_Log] (
    [ID]          INT      IDENTITY (1, 1) NOT NULL,
    [PropertyID]  INT      NULL,
    [Date]        DATE     NULL,
    [LocationID]  INT      NULL,
    [SysDateTime] DATETIME NULL
);


GO

