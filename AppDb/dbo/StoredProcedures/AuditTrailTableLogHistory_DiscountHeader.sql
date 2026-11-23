-- =============================================
-- Author:		Nivesh
-- Create date: 2024-03-15
-- Description:	Get Discount related log details
-- =============================================

-- AuditTrailTableLogHistory_DiscountHeader 65, 1
create PROCEDURE [dbo].[AuditTrailTableLogHistory_DiscountHeader] 
	@DiscountHeaderID INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY

		IF NOT EXISTS(SELECT 1 FROM HotelResWeb_AuditTail.sys.tables WHERE name = 'DiscountHeader_History')
		BEGIN
			RAISERROR('Log table not exists',16,1)
			RETURN
		END

		SELECT DISTINCT 
		DHH.AuditLoggedTxnDateTime AS LogDate, 
		DHH.AuditTrailID, 
		ATM.PropertyId,
		[dbo].[GET_User](ATM.UserID) AS UserName,
		CASE 
			WHEN ATM.Action = 'U' THEN 'Updated'  
			WHEN ATM.Action = 'I' THEN 'Created' 
		END AS Action,
		ATM.DatabaseName, 
		ATM.TableName,
		0 AS IsLocations,
		0 AS IsDays,
		0 AS IsDetails,
		CASE 
			WHEN ATM.Action = 'I' THEN 
				(SELECT * FROM (
					SELECT 
						JSON_VALUE(value, '$.Code') AS ID, 
						(SELECT TOP 1 name FROM locations WHERE id = JSON_VALUE(value, '$.Code')) AS Name
					FROM OPENJSON(JSON_QUERY(DHH.OutletListJson))
				) AS UnitConvertion FOR JSON PATH) 
			ELSE NULL 
		END AS LocationJson,
		CASE 
			WHEN ATM.Action = 'I' THEN DHH.DaysJson 
			ELSE NULL 
		END AS DaysJson,
		(
			SELECT * FROM (
				SELECT DISTINCT 
					DHHT.AuditTrailID,
					CASE WHEN ATD.FieldName ='DaysJson' THEN 'Days' 
						WHEN ATD.FieldName ='OutletListJson' THEN 'Locations'
						WHEN ATD.FieldName ='IsActive' THEN 'Active'
						WHEN ATD.FieldName ='IsAutoApply' THEN 'AutoApply'
						WHEN ATD.FieldName ='IsAuthorization' THEN 'Authorization'
						WHEN ATD.FieldName ='IsNeedRemark' THEN 'NeedRemark'
						WHEN ATD.FieldName ='IsApplyAllItems' THEN 'Apply All Items'
						WHEN ATD.FieldName ='IsPercentage' THEN 'Percentage'
						WHEN ATD.FieldName ='Percentage' THEN 'Percentage value'
					ELSE ATD.FieldName END FieldName,
					CASE 
						WHEN ATD.FieldName IN ('IsAutoApply', 'IsAuthorization', 'IsDay', 'IsNeedRemark', 'IsValidatePayType', 'IsItemWiseDiscount', 'IsActive', 'IsPercentage', 'IsUpload', 'IsApplyAllItems') 
						THEN 
							CASE WHEN ATD.OldValue = 0 THEN 'False' ELSE 'True' END
						ELSE ATD.OldValue
					END AS OldValue,
					CASE 
						WHEN ATD.FieldName IN ('IsAutoApply', 'IsAuthorization', 'IsDay', 'IsNeedRemark', 'IsValidatePayType', 'IsItemWiseDiscount', 'IsActive', 'IsPercentage', 'IsUpload', 'IsApplyAllItems') 
						THEN 
							CASE WHEN ATD.NewValue = 0 THEN 'False' ELSE 'True' END
						ELSE ATD.NewValue 
					END AS NewValue,
					CASE 
						WHEN ATD.FieldName = 'OutletListJson' 
						THEN (
							SELECT * FROM (
								SELECT 
									JSON_VALUE(value, '$.Code') AS ID, 
									(SELECT TOP 1 name FROM locations WHERE id = JSON_VALUE(value, '$.Code')) AS Name
								FROM OPENJSON(JSON_QUERY('[' + REPLACE(ATD.OldValue, '\', '') + ']'))
							) AS UnitConvertion FOR JSON PATH
						) 
						ELSE NULL 
					END AS OldLocations,
					CASE 
						WHEN ATD.FieldName = 'OutletListJson' 
						THEN (
							SELECT * FROM (
								SELECT 
									JSON_VALUE(value, '$.Code') AS ID, 
									(SELECT TOP 1 name FROM locations WHERE id = JSON_VALUE(value, '$.Code')) AS Name
								FROM OPENJSON(JSON_QUERY('[' + REPLACE(ATD.NewValue, '\', '') + ']'))
							) AS UnitConvertion FOR JSON PATH
						) 
						ELSE NULL 
					END AS NewLocations
				FROM 
					HotelResWeb_AuditTail..DiscountHeader_History DHHT
					INNER JOIN HotelResWeb_AuditTail..[AuditTrailMaster] ATM ON ATM.TrailID = DHHT.AuditTrailID
					LEFT JOIN HotelResWeb_AuditTail..[AuditTrailDetail] ATD ON ATD.TrailID = DHHT.AuditTrailID
				WHERE 
					DHHT.id = @DiscountHeaderID 
					AND DHHT.AuditTrailID = DHH.AuditTrailID 
					AND DHHT.PropertyId = @PropertyID 
					AND (
						(ATD.FieldName = 'Percentage' AND REPLACE(ATD.NewValue, '.00', '') <> ATD.OldValue) OR
						(ATD.FieldName = 'DiscountValue' AND REPLACE(ATD.NewValue, '.00', '') <> ATD.OldValue) OR
						(ATD.FieldName = 'MaxDiscountAmount' AND REPLACE(ATD.NewValue, '.00', '') <> ATD.OldValue) OR
						(ATD.FieldName = 'MinInvoiceAmount' AND REPLACE(ATD.NewValue, '.00', '') <> ATD.OldValue) OR
						ATD.FieldName NOT IN ('Percentage', 'DiscountValue', 'MaxDiscountAmount', 'MinInvoiceAmount')
					)
			) AS AuditTrailData FOR JSON PATH
		) AS AuditTrailData
	FROM 
		HotelResWeb_AuditTail..DiscountHeader_History DHH
		INNER JOIN HotelResWeb_AuditTail..[AuditTrailMaster] ATM ON ATM.TrailID = DHH.AuditTrailID
		LEFT JOIN HotelResWeb_AuditTail..[AuditTrailDetail] ATD ON ATD.TrailID = DHH.AuditTrailID
	WHERE 
		DHH.id = @DiscountHeaderID 
		AND DHH.PropertyId = @PropertyID 
	ORDER BY 
		DHH.AuditLoggedTxnDateTime DESC;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

