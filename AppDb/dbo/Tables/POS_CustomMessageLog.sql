CREATE TABLE [dbo].[POS_CustomMessageLog] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [ContactNumber] NVARCHAR (20)  NULL,
    [Message]       NVARCHAR (MAX) NULL,
    [Type]          NVARCHAR (20)  NULL,
    [SysDateTime]   DATETIME       NULL,
    [IsSent]        BIT            NULL,
    [Outlet]        NVARCHAR (20)  NULL,
    [PropertyID]    INT            NULL,
    CONSTRAINT [PK_POS_CustomMessageLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

