CREATE TABLE [dbo].[ReservationPayment] (
    [ReservationNo] INT             NOT NULL,
    [PayCode]       VARCHAR (2)     NOT NULL,
    [PayType]       VARCHAR (20)    NOT NULL,
    [Amount]        NUMERIC (18, 4) CONSTRAINT [DF_ReservationPayment_AdvanceAmount] DEFAULT ((0)) NOT NULL,
    [Remark]        VARCHAR (30)    CONSTRAINT [DF_ReservationPayment_Remark] DEFAULT (' ') NOT NULL,
    [CreateUser]    VARCHAR (20)    CONSTRAINT [DF_ReservationPayment_CreateUser] DEFAULT ('') NOT NULL,
    [CreateDate]    SMALLDATETIME   CONSTRAINT [DF_ReservationPayment_CreateDate] DEFAULT (getdate()) NOT NULL,
    [IsCancel]      BIT             CONSTRAINT [DF_ReservationPayment_IsCancel] DEFAULT ((0)) NOT NULL,
    [CancelUser]    VARCHAR (20)    CONSTRAINT [DF_ReservationPayment_CancelUser] DEFAULT ('') NOT NULL,
    [CancelDate]    SMALLDATETIME   CONSTRAINT [DF_ReservationPayment_CancelDate] DEFAULT (getdate()) NOT NULL,
    [ShiftID]       BIGINT          CONSTRAINT [DF_ReservationPayment_ShiftID] DEFAULT ((0)) NOT NULL,
    [Outlet]        CHAR (3)        CONSTRAINT [DF_ReservationPayment_Outlet] DEFAULT ((1)) NOT NULL,
    [IsUpload]      BIT             NULL,
    [PropertyId]    INT             NOT NULL,
    [Id]            BIGINT          IDENTITY (1, 1) NOT NULL
);


GO

