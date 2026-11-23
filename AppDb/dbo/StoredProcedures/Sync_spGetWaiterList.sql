



CREATE PROCEDURE [dbo].[Sync_spGetWaiterList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	Code, Name, CardNo, Active, IsViewAllOrders, IsCashier
		FROM	Waiter
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  W.Code, W.Name, W.CardNo, W.Active, W.IsViewAllOrders, W.IsCashier
		FROM    Sync_MasterDataTransferStatus S INNER JOIN Waiter W ON S.Code = W.Code AND S.PropertyId = W.PropertyId
		WHERE	S.DataType = 'Waiter' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

