CREATE PROCEDURE [dbo].[SelectAllProfomaInvoiceApproval] 

	@UserProfileId	INT = -1,
  --@LocationID		INT = 52,
	@PropertyID		INT = -1
AS
BEGIN
	
	SET NOCOUNT ON;
 
    SELECT DISTINCT al.ApprovalLogID,
				al.SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				al.TransactionHeaderID,
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				al.ApprovalDate,
				al.IsComplete,
				al.DocStatus,
				al.PropertyID,
				al.LocationID,
				al.TransactionID,
				UserToApprove.UserProfileID,
				UserToApprove.SeqID,
				UserToApprove.TransationTypeName,
				UserToApprove.Location,
				UserToApprove.Code,
				UserToApprove.ApprovalTypeID,
				IMP_PIH.Id AS 'PIID',
				UserToApprove.PropertyID,
				UserToApprove.LocationID,
				'1' AS 'RequestType',
				IMP_PIH.DocumentNo,
				IMP_PIH.CreatedDate AS 'CreatedDate',
				IMP_PIH.DocumentStatus,
				UserToApprove.UserProfileID,
				1 AS 'JobNo',
				IMP_PIH.IsApproved,
				IMP_PIH.Remarks,
				1 AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				1 AS 'TransactionTypeID', --txnTypeId
				UserToApprove.userprofileID,
				userName,
				password,
				firstName,
				lastName,
				communicationTypeID1,
				communicationTypeID2,
				communicationTypeID3,
				communicationTypeID4,
				contactValue1,
				contactValue2,
				contactValue3,
				contactValue4,
				up.createdUserID,
				al.LastModUserID,
				up.CreatedDate,
				up.LastModDate,
				isActive,
				IMP_PIH.UserProfileID AS 'ReqUser',
				up.firstName+' '+up.lastName AS 'ReqUserName',
				(SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.ProformaInvoiceDetails WHERE PIID = al.TransactionHeaderID) AS 'ValueOfRequest'
	FROM dbo.ApprovalLogs al INNER JOIN( SELECT ta.PropertyID,ta.LocationID
											 , ta.TransactionID 
											 , ua.UserProfileID
											 , ta.SeqID,tt.Name AS 'TransationTypeName'
											 , ld.Name 'Location'
											 , tt.Code AS 'Code' 
											 , ta.ApprovalTypeID 
										FROM dbo.UserWiseApproveLevels ua INNER JOIN dbo.TransactionWiseApprovalTypes ta ON ua.approvelevelID =ta.ApprovalTypeID 
																												  AND ua.locationID=ta.locationID 
																												  AND ua.propertyID=ta.PropertyID
																	 INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	 INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										WHERE ua.userprofileID= 18 
										AND ua.PropertyID = 10 
										AND tt.Id = 30 
										AND ta.TransactionID = 30 
										AND ua.TransactionTypeID = 30 
										) UserToApprove ON al.PropertyID=UserToApprove.PropertyID

							INNER JOIN dbo.ProfomaInvoiceHeaders AS IMP_PIH ON IMP_PIH.Id = al.TransactionHeaderID 
																		AND UserToApprove.PropertyID = UserToApprove.PropertyID  
																		AND al.LocationID = UserToApprove.LocationID
																		AND al.LocationID=UserToApprove.LocationID 
																		AND al.TransactionID = UserToApprove.TransactionID 
																		AND IsComplete=0 
																		AND UserToApprove.SeqID = al.SeqID	
							INNER JOIN dbo.UserProfiles up ON up.Id = UserToApprove.UserProfileID
	WHERE al.SeqID  in (  SELECT MIN(seqID) 
							FROM dbo.ApprovalLogs
							WHERE IsComplete = 0 
							AND PropertyID =10
							--AND LocationID =@LocationID 
							AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
							AND TransactionHeaderID = al.TransactionHeaderID  )  
	
END

GO

