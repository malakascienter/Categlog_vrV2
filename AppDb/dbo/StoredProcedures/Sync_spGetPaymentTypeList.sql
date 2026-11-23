CREATE PROCEDURE [dbo].[Sync_spGetPaymentTypeList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	PayCode, Description, Cash, CreditCard, Credit, Voucher, IsECR, IsEWallet, IsRoomPosting, Remarks, DrawerOpen, Active, SortOrder, 
				IsAdvance, IsNeedPermission
		FROM	PaymentTypes
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  P.PayCode, P.Description, P.Cash, P.CreditCard, P.Credit, P.Voucher, P.IsECR, P.IsEWallet, P.IsRoomPosting, P.Remarks, P.DrawerOpen, S.Active, P.SortOrder, 
				P.IsAdvance, P.IsNeedPermission
		FROM    Sync_MasterDataTransferStatus S INNER JOIN PaymentTypes P ON S.Code = P.PayCode AND S.PropertyId = P.PropertyId
		WHERE	S.DataType = 'PaymentTypes' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

