CREATE TABLE [dbo].[POS_Rider] (
    [RiderID]   INT          CONSTRAINT [DF_Rider_RiderID] DEFAULT ((0)) NOT NULL,
    [RiderName] VARCHAR (50) CONSTRAINT [DF_Table_2_RiderID1] DEFAULT ('') NOT NULL,
    [Outlet]    VARCHAR (3)  CONSTRAINT [DF_Rider_Outlet] DEFAULT ('') NOT NULL,
    [IsActive]  BIT          CONSTRAINT [DF_Rider_IsActive] DEFAULT ((0)) NOT NULL,
    [EditUser]  VARCHAR (20) CONSTRAINT [DF_Rider_EditUser] DEFAULT ('') NOT NULL,
    [EditDate]  DATETIME     CONSTRAINT [DF_Table_2_EditUser1] DEFAULT (getdate()) NOT NULL
);


GO

